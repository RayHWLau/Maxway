# Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## CampaignMember WhatsApp Auto-Response

[CampaignMember_WhatsApp_Auto_Response](force-app/main/default/flows/CampaignMember_WhatsApp_Auto_Response.flow-meta.xml) is an API 68.0 after-create record-triggered publisher. It runs only when the related Campaign's Type is `Seminar / Event`; updates do not publish or resend messages. The publisher does not access WatBox objects or invoke package code.

Processing is split into two parts:

1. The publisher creates [Campaign_Member_Package_Trigger__e](force-app/main/default/objects/Campaign_Member_Package_Trigger__e/Campaign_Member_Package_Trigger__e.object-meta.xml), containing only the required 18-character `CampaignMemberId__c`. Its publish behavior is **Publish After Commit**.
2. [CampaignMemberPackageEvent](force-app/main/default/triggers/CampaignMemberPackageEvent.trigger) receives events as the licensed user and calls [CampaignMemberPackageSubscriber](force-app/main/default/classes/CampaignMemberPackageSubscriber.cls). It invokes [PE_Execute_CampaignMember_Package_Action](force-app/main/default/flows/PE_Execute_CampaignMember_Package_Action.flow-meta.xml), an **autolaunched** processing flow, in one bulk action invocation. The subscriber batch size is 200.

The [subscriber configuration](force-app/main/default/platformEventSubscriberConfigs/CampaignMemberPackageEvent.platformEventSubscriberConfig-meta.xml) selects `cs@maxway-edu.net` as the running user. The deployment user is independent of this execution identity. System mode does not bypass WatBox license checks.

A Platform Event-triggered Flow is deliberately not used: [Salesforce documents that event-triggered Flow interviews retain the publisher's user context](https://developer.salesforce.com/docs/platform/platform-events/guide/platform-events-subscribe-flow.html). [PlatformEventSubscriberConfig](https://developer.salesforce.com/docs/platform/api-metadata/references/meta-types/metadata-platformeventsubscriberconfig.html) configures Apex triggers, not Flow subscriptions; this was also verified against the org's API 68.0 Tooling API.

The processing flow queries the committed CampaignMember and Campaign. If the Campaign no longer has Type `Seminar / Event`, processing ends without sending. Otherwise, before invoking WatBox, it overwrites these temporary fields on the Lead, or on both the Contact and its related Account:

| Temporary field | Campaign source |
| --- | --- |
| `Temp_Display_Campaign_Name__c` | `Display_Campaign_Name__c` |
| `Temp_Display_Campaign_Start_Date__c` | `Display_Campaign_Start_Date__c` |
| `Temp_Display_Campaign_Start_Time__c` | `Campaign_Start_Time__c` |

The flow adds these values to `bodyParams` in the table's order and retrieves the first `watbox_platform__Template__c` named `generic_attend_seminar_confirmation`. It passes the template's WhatsApp business number and name to `watbox_platform__SendWAMessage`, using `CampaignMember.LeadOrContactId` and its ID prefix (`00Q` for Lead, `003` for Contact) for the recipient record and object type. The destination number is `Lead.Mobile__c` for Leads and `Account.Mobile__c` for Contacts. `runAsync` is true; `buttonParams`, `msg`, and other optional inputs remain unassigned.

The processing flow retrieves the CampaignMember by its `campaignMemberId` input rather than using a derived field on the publisher's `$Record`.

The Contact update explicitly sets only the three temporary fields, filtered by the member's Contact ID. It does not write the entire queried Contact record: for Person Accounts, Salesforce maps Contact updates to Account updates, where the retrieved `AccountId` field is invalid.

The publisher is supplied as **Draft**; the autolaunched processing flow is **Active** so Apex can invoke it. The processing flow alone does not subscribe to events or run automatically. The dedicated [deployment manifest](manifest/campaign-member-package.xml) includes the event, field, flows, permission set, Apex subscriber, tests, and running-user configuration.

On the first deployment, deploy **only** the processing flow before validating the complete manifest:

```sh
sf project deploy start \
  --source-dir force-app/main/default/flows/PE_Execute_CampaignMember_Package_Action.flow-meta.xml \
  --api-version 68.0 --target-org maxway
```

Explicitly activate the latest processing-flow version in Flow Builder. This org saves deployed flows as Draft even when their source metadata says Active. Confirm `FlowDefinition.ActiveVersionId` is populated using the Tooling API; until then the Flow action is not registered, and Apex invocations can fail with Salesforce internal error `-1358005683`. Repeat this processing-flow deployment and activation first when changing its logic.

Once the processing flow is active, validate the rest without deploying:

```sh
sf project deploy start --manifest manifest/campaign-member-package.xml \
  --api-version 68.0 --dry-run --test-level RunSpecifiedTests \
  --tests CampaignMemberPackageSubscriberTest --target-org maxway
```

Deployment and license handoff:

1. Deploy the manifest with the authenticated deployment user, omitting `--dry-run` only when ready.
2. Assign [Campaign_Member_Package_Publisher](force-app/main/default/permissionsets/Campaign_Member_Package_Publisher.permissionset-meta.xml) to users allowed to publish requests. It grants Create and Read access to the event (Salesforce requires Read for Create), not access to WatBox.
3. Before enabling processing, assign the WatBox license and its required permissions to `cs@maxway-edu.net`. The license can remain with the deployment user during implementation and validation. Ensure the CS user remains active.
4. Verify the Apex subscription's configured user is CS in Setup / Platform Event subscriptions, or inspect `PlatformEventSubscriberConfig` with the Tooling API. Do not attempt to configure a Flow subscription as the licensed user.
5. Verify the **autolaunched processing flow is active**, then activate the publisher. Retire any older active publisher version that still calls WatBox directly.
6. Create an eligible CampaignMember as an unlicensed user and verify processing as CS, including a Person Account Contact. Do this only when ready to send a real message.

Contact members require a related Account. Ensure the recipient mobile number, Campaign display values, and WatBox template business number are populated. Temporary fields hold the latest processed Campaign details, not a history; values are read when the event is processed, not snapshotted at publication.

Lookup, update, and action fault paths return `errorMessage` to Apex. Missing members and unsupported recipients also return explicit errors. Apex logs these at ERROR level and throws, failing the event batch rather than silently dropping failures. Monitor the Apex subscription's error state and debug logs for its configured running user; investigate before resuming or replaying a failed batch. Event processing failures happen after commit and cannot roll back the original CampaignMember insertion. WatBox delivery failures after its own asynchronous handoff must be monitored in WatBox. Platform Event delivery is at least once; this implementation does not add a persistent message-deduplication ledger.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
