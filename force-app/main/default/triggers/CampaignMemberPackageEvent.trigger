trigger CampaignMemberPackageEvent on Campaign_Member_Package_Trigger__e (after insert) {
    CampaignMemberPackageSubscriber.processEvents(Trigger.new);
}
