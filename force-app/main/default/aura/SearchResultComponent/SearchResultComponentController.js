({
    //if you are planning to add new column in any of lighting data table, just be sure that
    //first column (row index) will be automatically hide as per current CSS
    HSdoInit: function (component, event, helper) {
        component.set("v.spinneristrue", true);
        var schoolcolum = [];
        /*
         * {
                label: "S.No",
                fieldName: "sNo",
                initialWidth: 100,
                type: "text",
                sortable: false,
            },
        */
        schoolcolum = [
            
            {
                label: "Sr.No.",
                fieldName: "sNo",
                initialWidth: 80,
                type: "text",
                sortable: true,
            },
            {
                label: "Select",
                fieldName: "isChecked",
                initialWidth: 100,
                type: "boolean",
                sortable: true,
                editable: true,
            },
            
            {
                label: "Name",
                fieldName: "SchoolId",
                initialWidth: 250,
                type: "url",
                sortable: true,
                typeAttributes: {
                    label: { fieldName: "Name" },
                    target: "_blank",
                    sortable: true,
                },
            },
            {
                label: "Province",
                fieldName: "Province",
                initialWidth: 150,
                type: "text",
                sortable: true,
            },
            {
                label: "City",
                fieldName: "City",
                initialWidth: 150,
                type: "text",
                sortable: true,
            },
            {
                label: "Gender",
                fieldName: "Gender",
                initialWidth: 100,
                type: "text",
                sortable: true,
            },
            {
                label: "Program",
                fieldName: "program",
                initialWidth: 150,
                type: "text",
                sortable: true,
            },
            {
                label: "Fee",
                fieldName: "Budget",
                type: "text",
                initialWidth: 150,
                sortable: true,
            },
        ];
            
            //
            if (
            $A
            .get("$Label.c.IBStudentHSFilter")
            .includes(event.getParam("programtype"))
            ) {
            var school = {
            label: "IB Score",
            fieldName: "IB",
            initialWidth: 100,
            type: "text",
            sortable: true,
            };
            schoolcolum.push(school);
            var school1 = {
            label: "IB %",
            fieldName: "IBStudent",
            initialWidth: 100,
            type: "text",
            sortable: true,
            };
            schoolcolum.push(school1);
            
            for (var index = 0; index < schoolcolum.length; index++) {
            if (schoolcolum[index].fieldName == "program") {
                schoolcolum.splice(index, 1);
            }
        if (schoolcolum[index].fieldName == "Budget") {
            schoolcolum[index].sortable = true;
        }
    }
}
 //
 else if ($A.get("$Label.c.ATAR").includes(event.getParam("country"))) {
    var school = {
        label: "ATAR",
        fieldName: "ATAR",
        initialWidth: 100,
        type: "text",
        sortable: true,
    };
    schoolcolum.push(school);
    
    for (var index = 0; index < schoolcolum.length; index++) {
        console.log(schoolcolum[index].label);
    }
}
//
else if (
    $A.get("$Label.c.SATACTHSFilter").includes(event.getParam("country"))
) {
    var school = {
        label: "SAT",
        fieldName: "SAT",
        type: "text",
        initialWidth: 80,
        sortable: true,
    };
    
    schoolcolum.push(school);
    
    var school1 = {
        label: "ACT",
        fieldName: "ACT",
        type: "text",
        initialWidth: 80,
        sortable: true,
    };
    
    schoolcolum.push(school1);
} else if (
    
    /*
if($A.get("$Label.c.ALevel").includes(event.getParam("programtype")) ||($A.get("$Label.c.All_Grades_Offered_United_Kingdom").includes(event.getParam("programtype")) && $A.get("$Label.c.All_Grades_Offered_United_Kingdom").includes(event.getParam("country")))){

var school = {label: 'A Level', fieldName: 'ALevel', type: 'text',initialWidth:100, sortable: true};
schoolcolum.push(school);
}

if($A.get("$Label.c.ALevel").includes(event.getParam("programtype")) ||($A.get("$Label.c.All_Grades_Offered_United_Kingdom").includes(event.getParam("programtype")) && $A.get("$Label.c.All_Grades_Offered_United_Kingdom").includes(event.getParam("country")))){
var school = {label: 'A Level Range', fieldName: 'ALevelRange', type: 'text',initialWidth:100, sortable: true};
schoolcolum.push(school);
}*/
    $A
    .get("$Label.c.All_Grades_Offered_United_Kingdom")
    .includes(event.getParam("country"))
) {
    var school = {
        label: "A Level",
        fieldName: "ALevel",
        type: "text",
        initialWidth: 100,
        sortable: true,
    };
    schoolcolum.push(school);
    //}
    
    //if( $A.get("$Label.c.All_Grades_Offered_United_Kingdom").includes(event.getParam("country"))){
    var school1 = {
        label: "Range",
        fieldName: "ALevelRange",
        type: "text",
        initialWidth: 100,
        sortable: true,
    };
    schoolcolum.push(school1);
    
    for (var index = 0; index < schoolcolum.length; index++) {
        if (schoolcolum[index].fieldName == "Budget") {
            schoolcolum[index].sortable = true;
        }
    }
}
/*
if($A.get("$Label.c.GCSE").includes(event.getParam("programtype"))){
var school = {label: 'GCSE', fieldName: 'GCSE', type: 'text',initialWidth:100, sortable: true};
schoolcolum.push(school);
}

if($A.get("$Label.c.GCSE").includes(event.getParam("programtype"))){
var school = {label: 'GCSE Range', fieldName: 'GCSERange', type: 'text',initialWidth:100, sortable: true};
schoolcolum.push(school);
}
*/
//if(!$A.util.isEmpty(event.getParam("province"))) {
    else if (
        $A
        .get("$Label.c.FraserinstituteHSFilter")
        .includes(event.getParam("country"))
    ) {
        //&& $A.get("$Label.c.FraserinstituteHSFilter").includes(event.getParam("province"))
        var school = {
            label: "Fraser",
            fieldName: "Fraserinstitute",
            type: "text",
            initialWidth: 100,
            sortable: true,
        };
        schoolcolum.push(school);
    } else {
        for (var index = 0; index < schoolcolum.length; index++) {
            if (schoolcolum[index].fieldName == "program") {
                schoolcolum.splice(index, 1);
            }
        }
    }
//}
var schoolFlyer = {
    label: "",
    fieldName: "flyerLink",
    initialWidth: 250,
    type: "url",
    sortable: true,
    typeAttributes: { target: "_blank", label: "Download Flyer" },
};
schoolcolum.push(schoolFlyer);

component.set("v.ScheoolColumns", schoolcolum);

var action = component.get("c.returnSearchedHighSchool");
action.setParams({
    nationality: event.getParam("nationality"),
    country: event.getParam("country"),
    programtype: event.getParam("programtype"),
    minbudget: event.getParam("minbudget"),
    maxbudget: event.getParam("maxbudget"),
    grade: event.getParam("grade"),
    province: event.getParam("province"),
    city: event.getParam("city"),
    housing: event.getParam("housing"),
    currencycode: event.getParam("currencycode"),
});
action.setCallback(this, function (response) {
    if (response.getState() === "SUCCESS") {
        component.set("v.ScheoolRecords", response.getReturnValue());
        if (response.getReturnValue() != null) {
            if (response.getReturnValue().length != 0) {
                component.set("v.isSectionShow", false);
                component.set(
                    "v.totalSchool",
                    response.getReturnValue()[0].totalSchoolANdProg
                );
                
                
                //added on 9 may 2020 for pagination
                var pageSize = component.get("v.pageSize");
                component.set("v.totalRecords", response.getReturnValue().length);
                component.set("v.startPage", 0);                
                component.set("v.endPage", pageSize - 1);
                
                component.set('v.ScheoolRecordsToShow', response.getReturnValue().splice(0,pageSize));
                
                //end pagination
            } else {
                component.set("v.isSectionShow", true);
            }
        } else {
            component.set("v.isSectionShow", true);
        }
    } else if (response.getState() === "ERROR") {
        var errors = response.getError();
        console.error(errors);
    }
    component.set("v.spinneristrue", false);
});
$A.enqueueAction(action);
},
    PSdoInit: function (component, event, helper) {
        component.set("v.spinneristrue", true);
        var schoolcolum = [];
        schoolcolum = [
            {
                label: "Sr.No.",
                fieldName: "sNo",
                initialWidth: 80,
                type: "text",
                sortable: true,
            },
            {
                label: "Select",
                fieldName: "isChecked",
                initialWidth: 100,
                type: "boolean",
                sortable: true,
                editable: true
            },
            {
                label: "Campus Name",
                fieldName: "SchoolId",
                initialWidth: 250,
                type: "url",
                sortable: true,
                typeAttributes: { label: { fieldName: "Name" }, target: "_blank" },
            },
            {
                label: "Province",
                fieldName: "Province",
                initialWidth: 150,
                type: "text",
                sortable: true,
            },
            {
                label: "City",
                fieldName: "City",
                initialWidth: 150,
                type: "text",
                sortable: true,
            },
            {
                label: "World Ranked?",
                fieldName: "worldRank",
                initialWidth: 100,
                type: "text",
                sortable: true,
            },
            {
                label: "Program",
                fieldName: "Program",
                initialWidth: 100,
                type: "text",
                sortable: true,
            },
            {
                label: "Duration",
                fieldName: "ProgramDuration",
                type: "text",
                initialWidth: 100,
                sortable: true,
            },
            {
                label: "Unit",
                fieldName: "DurationUnit",
                type: "text",
                initialWidth: 100,
                sortable: true,
            },
            {
                label: "Cost",
                fieldName: "AnnualFees",
                type: "text",
                initialWidth: 80,
                sortable: true,
            },
            {
                label: "IELTS",
                fieldName: "IELTSMin",
                type: "text",
                initialWidth: 100,
                sortable: true,
            },
            {
                label: "IELTS Upgrade?",
                fieldName: "ieltsUpgrade",
                type: "text",
                initialWidth: 100,
                sortable: true,
            },
            {
                label: "TOEFL",
                fieldName: "TOEFLMin",
                type: "text",
                initialWidth: 100,
                sortable: true,
            },
            {
                label: "TOEFL Upgrade?",
                fieldName: "toeflUpgrade",
                type: "text",
                initialWidth: 100,
                sortable: true,
            },
            
            //     {label: 'Months of Intake', fieldName: 'MonthsofIntake', type: 'text',initialWidth:80, sortable: false},
        ];
            
            //if toefl isnot empty
            if (
            !$A.util.isEmpty(event.getParam("toefl")) &&
            $A.util.isEmpty(event.getParam("ielts"))
            ) {
            for (var index = 0; index < schoolcolum.length; index++) {
            if (schoolcolum[index].fieldName == "IELTSMin") {
                schoolcolum.splice(index, 1);
            }
        if (schoolcolum[index].fieldName == "ieltsUpgrade") {
            schoolcolum.splice(index, 1);
        }
    }
var school1 = {
    label: "Lowest TOEFL?",
    fieldName: "LowestTOEFLforEnglishUpgrade",
    type: "text",
    initialWidth: 100,
    sortable: true,
};
schoolcolum.push(school1);
component.set("v.ScheoolColumns", schoolcolum);
}
//if ielts is not empty
else if (
    !$A.util.isEmpty(event.getParam("ielts")) &&
    $A.util.isEmpty(event.getParam("toefl"))
) {
    for (var index = 0; index < schoolcolum.length; index++) {
        if (schoolcolum[index].fieldName == "TOEFLMin") {
            schoolcolum.splice(index, 1);
        }
        if (schoolcolum[index].fieldName == "toeflUpgrade") {
            schoolcolum.splice(index, 1);
        }
    }
    var school1 = {
        label: "Lowest IELTS?",
        fieldName: "LowestIELTSforEnglishUpgrade",
        type: "text",
        initialWidth: 100,
        sortable: true,
    };
    schoolcolum.push(school1);
    component.set("v.ScheoolColumns", schoolcolum);
}
var school1 = {
    label: "",
    fieldName: "majorLink",
    initialWidth: 150,
    type: "url",
    sortable: true,
    typeAttributes: { target: "_blank", label: "Available Major" },
};
schoolcolum.push(school1);
var schoolFlyer = {
    label: "",
    fieldName: "flyerLink",
    initialWidth: 150,
    type: "url",
    sortable: true,
    typeAttributes: { target: "_blank", label: "Download Flyer" },
};
schoolcolum.push(schoolFlyer);
component.set("v.ScheoolColumns", schoolcolum);

var action = component.get("c.returnSearchedcollegeSchool");
action.setParams({
    nationality: event.getParam("nationality"),
    country: event.getParam("country"),
    programtype: event.getParam("programtype"),
    minbudget: event.getParam("minbudget"),
    maxbudget: event.getParam("maxbudget"),
    programobjective: event.getParam("programobjective"),
    province: event.getParam("province"),
    city: event.getParam("city"),
    Major: event.getParam("Major"),
    currencycode: event.getParam("currencycode"),
    highschoolgrad: event.getParam("highschoolgrad"),
    toefl: event.getParam("toefl"),
    ielts: event.getParam("ielts"),
    recordtype: event.getParam("recordtype"),
});
action.setCallback(this, function (response) {
    if (response.getState() === "SUCCESS") {
        component.set("v.ScheoolRecords", response.getReturnValue());
        
        if (response.getReturnValue() != null) {
            if (response.getReturnValue().length != 0) {
                component.set("v.isSectionShow", false);
                component.set(
                    "v.totalSchool",
                    response.getReturnValue()[0].totalSchoolANdProg
                );
                
                
                //added on 9 may 2020 for pagination
                var pageSize = component.get("v.pageSize");
                component.set("v.totalRecords", response.getReturnValue().length);
                component.set("v.startPage", 0);                
                component.set("v.endPage", pageSize - 1);
                
                component.set('v.ScheoolRecordsToShow', response.getReturnValue().splice(0,pageSize));
                
                //end pagination
            } else {
                component.set("v.isSectionShow", true);
            }
        } else {
            component.set("v.isSectionShow", true);
        }
    } else if (response.getState() === "ERROR") {
        var errors = response.getError();
        console.error(errors);
    }
    component.set("v.spinneristrue", false);
});
$A.enqueueAction(action);
},
    
    PGdoInit: function (component, event, helper) {
        component.set("v.spinneristrue", true);
        var schoolcolum = [];
        schoolcolum = [
            {
                label: "Sr.No.",
                fieldName: "sNo",
                initialWidth: 80,
                type: "text",
                sortable: true,
            },
            {
                label: "Select",
                fieldName: "isChecked",
                initialWidth: 100,
                type: "boolean",
                sortable: true,
                editable: true
            },
            
            {
                label: "Campus Name",
                fieldName: "SchoolId",
                initialWidth: 250,
                type: "url",
                sortable: true,
                typeAttributes: { label: { fieldName: "Name" }, target: "_blank" },
            },
            {
                label: "Province",
                fieldName: "Province",
                initialWidth: 150,
                type: "text",
                sortable: true,
            },
            {
                label: "City",
                fieldName: "City",
                initialWidth: 150,
                type: "text",
                sortable: true,
            },
            {
                label: "World Ranked?",
                fieldName: "worldRank",
                initialWidth: 100,
                type: "text",
                sortable: true,
            },
            {
                label: "Program",
                fieldName: "Program",
                initialWidth: 100,
                type: "text",
                sortable: true,
            },
            {
                label: "Duration",
                fieldName: "ProgramDuration",
                type: "text",
                initialWidth: 100,
                sortable: true,
            },
            {
                label: "Unit",
                fieldName: "DurationUnit",
                type: "text",
                initialWidth: 100,
                sortable: true,
            },
            {
                label: "Cost",
                fieldName: "AnnualFees",
                type: "text",
                initialWidth: 80,
                sortable: true,
            },
            {
                label: "IELTS",
                fieldName: "IELTSMin",
                type: "text",
                initialWidth: 100,
                sortable: true,
            },
            {
                label: "IELTS Upgrade?",
                fieldName: "ieltsUpgrade",
                type: "text",
                initialWidth: 100,
                sortable: true,
            },
            {
                label: "TOEFL",
                fieldName: "TOEFLMin",
                type: "text",
                initialWidth: 100,
                sortable: true,
            },
            {
                label: "TOEFL Upgrade?",
                fieldName: "toeflUpgrade",
                type: "text",
                initialWidth: 100,
                sortable: true,
            },
            
            //     {label: 'Months of Intake', fieldName: 'MonthsofIntake', type: 'text',initialWidth:80, sortable: false},
        ];
            
            //if toefl isnot empty
            if (
            !$A.util.isEmpty(event.getParam("toefl")) &&
            $A.util.isEmpty(event.getParam("ielts"))
            ) {
            for (var index = 0; index < schoolcolum.length; index++) {
            if (schoolcolum[index].fieldName == "IELTSMin") {
                schoolcolum.splice(index, 1);
            }
        if (schoolcolum[index].fieldName == "ieltsUpgrade") {
            schoolcolum.splice(index, 1);
        }
    }
var school1 = {
    label: "Lowest TOEFL?",
    fieldName: "LowestTOEFLforEnglishUpgrade",
    type: "text",
    initialWidth: 100,
    sortable: true,
};
schoolcolum.push(school1);
component.set("v.ScheoolColumns", schoolcolum);
}
//if ielts is not empty
else if (
    !$A.util.isEmpty(event.getParam("ielts")) &&
    $A.util.isEmpty(event.getParam("toefl"))
) {
    for (var index = 0; index < schoolcolum.length; index++) {
        if (schoolcolum[index].fieldName == "TOEFLMin") {
            schoolcolum.splice(index, 1);
        }
        if (schoolcolum[index].fieldName == "toeflUpgrade") {
            schoolcolum.splice(index, 1);
        }
    }
    var school1 = {
        label: "Lowest IELTS?",
        fieldName: "LowestIELTSforEnglishUpgrade",
        type: "text",
        initialWidth: 100,
        sortable: true,
    };
    schoolcolum.push(school1);
    component.set("v.ScheoolColumns", schoolcolum);
}
var school1 = {
    label: "",
    fieldName: "majorLink",
    initialWidth: 150,
    type: "url",
    sortable: true,
    typeAttributes: { target: "_blank", label: "Available Major" },
};
schoolcolum.push(school1);
var schoolFlyer = {
    label: "",
    fieldName: "flyerLink",
    initialWidth: 150,
    type: "url",
    sortable: true,
    typeAttributes: { target: "_blank", label: "Download Flyer" },
};
schoolcolum.push(schoolFlyer);
component.set("v.ScheoolColumns", schoolcolum);

var action = component.get("c.returnSearchedcollegeSchool");
var action = component.get("c.returnSearcheduniversitySchool");
action.setParams({
    nationality: event.getParam("nationality"),
    country: event.getParam("country"),
    programtype: event.getParam("programtype"),
    minbudget: event.getParam("minbudget"),
    maxbudget: event.getParam("maxbudget"),
    programobjective: event.getParam("programobjective"),
    province: event.getParam("province"),
    city: event.getParam("city"),
    Major: event.getParam("Major"),
    currencycode: event.getParam("currencycode"),
    Bachloreneeded: event.getParam("Bachloreneeded"),
    toefl: event.getParam("toefl"),
    ielts: event.getParam("ielts"),
    recordtype: event.getParam("recordtype"),
});
action.setCallback(this, function (response) {
    if (response.getState() === "SUCCESS") {
        component.set("v.ScheoolRecords", response.getReturnValue());
        
        
        
        if (response.getReturnValue() != null) {
            if (response.getReturnValue().length != 0) {
                component.set("v.isSectionShow", false);
                component.set(
                    "v.totalSchool",
                    response.getReturnValue()[0].totalSchoolANdProg
                );
                
                //added on 9 may 2020 for pagination
                var pageSize = component.get("v.pageSize");
                component.set("v.totalRecords", response.getReturnValue().length);
                component.set("v.startPage", 0);                
                component.set("v.endPage", pageSize - 1);
                
                component.set('v.ScheoolRecordsToShow', response.getReturnValue().splice(0,pageSize));
                
                //end pagination
            } else {
                component.set("v.isSectionShow", true);
            }
        } else {
            component.set("v.isSectionShow", true);
        }
    } else if (response.getState() === "ERROR") {
        var errors = response.getError();
        console.error(errors);
    }
    component.set("v.spinneristrue", false);
});
$A.enqueueAction(action);
},
    updateColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam("fieldName");
        var sortDirection = event.getParam("sortDirection");
        // assign the latest attribute with the sorted column fieldName and sorted direction
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedColumnDirection", sortDirection);
        
        
        //as if there are some seleted rows( in draft values ) then it will save it.
        if( component.find("tableData").get("v.draftValues").length > 0 ){
            
            helper.handleSaveEditionHelp(component,event);
        }
        
        component.find("tableData").set("v.draftValues", null);
        
        helper.sortData(component, fieldName, sortDirection);
        
        //after sorting all column
        helper.handleNextHelp( component, event );
    },
        ClearSchoolResultAction: function (component, event) {
            component.set("v.spinneristrue", true);
            component.set("v.isSectionShow", true);
            component.set("v.ScheoolRecords", []);
            component.set("v.spinneristrue", false);
        },
            
            updateSelectedText: function (cmp, event) {
                var selectedRows = event.getParam("selectedRows");
                var selectedschool = [];
                for (var i = 0; i < selectedRows.length; i++) {
                    selectedschool.push(selectedRows[i].SchoolId);
                }
                cmp.set("v.selectedschoollist", selectedschool);
            },
                AddRecomendedSchool: function (cmp, event,helper) {
                    
                    //as if there are some seleted rows( in draft values ) then it will save it.
                    if( cmp.find("tableData").get("v.draftValues").length > 0 ){
                        
                        helper.handleSaveEditionHelp(cmp,event);
                    }
					cmp.set("v.searchTerm","");
					cmp.set("v.selectedOppRec","");  
                    cmp.set("v.oppRecColum","");  
                    cmp.set("v.showOppRecTable",false);  
                    
                    cmp.set("v.attachstudent", true);
                },
                    // Added By Ravi on 27 march 2020
                    cancel: function (cmp, event) {
                        cmp.set("v.attachstudent", false);
                    },
                        save: function (cmp, event) {
                            cmp.set("v.attachstudent", false);
                            cmp.set("v.spinneristrue", true);
                            var action = cmp.get("c.addRecomendedSchool");
                            
                            /*
                            action.setParams({
                                studentid: cmp.get("v.studentid"),
                                programlist: cmp.get("v.selectedschoollist"),
                            });*/
                            
                            //added after pagination
                            var listProg = [];
                            var listSchool = cmp.get('v.ScheoolRecords');
                            for( var index = 0; index< listSchool.length; index++ ){
                                
                                if( listSchool[index].isChecked )
                                    listProg.push(listSchool[index].SchoolId);
                            }
                            console.log(listProg);
                            action.setParams({
                                studentid: cmp.get("v.studentid"),
                                programlist: listProg,
                            });
                            //added after pagination
                            
                            action.setCallback(this, function (response) {
                                if (response.getState() === "SUCCESS") {
                                    if (response.getReturnValue().includes("success")) {
                                        cmp.set("v.spinneristrue", false);
                                        cmp.set("v.attachstudent", false);
                                        var toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            title: "Success!",
                                            message: "Successfully Inserted",
                                            type: "success",
                                        });
                                        toastEvent.fire();
                                    } else {
                                        cmp.set("v.spinneristrue", false);
                                        var toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            title: "Error!",
                                            message: response.getReturnValue(),
                                            type: "error",
                                        });
                                        toastEvent.fire();
                                    }
                                }
                            });
                            $A.enqueueAction(action);
                        },
                            //this is used to show the selected opp record on add recommended school option
                            //deprecated, instead searchOpp() is being used. Thisis store for future reference
                            fetchOppInfo: function (component, event) {
                                console.log("from js");
                                console.log(event.getParam("recordId"));
                                
                                if ($A.util.isEmpty(event.getParam("recordId"))) {
                                    component.set("v.selectedOppRec", "");
                                    component.set("v.showOppRecTable", false);
                                } else {
                                    var oppColum = [];
                                    oppColum = [
                                        {
                                            label: "",
                                            fieldName: "",
                                            initialWidth: 100,
                                            type: "text",
                                        },
                                        {
                                            label: "Student ID",
                                            fieldName: "studentId",
                                            initialWidth: 200,
                                            type: "text",
                                            sortable: false,
                                        },
                                        {
                                            label: "Student Name",
                                            fieldName: "studentName",
                                            initialWidth: 200,
                                            type: "text",
                                            sortable: false,
                                        },
                                        {
                                            label: "Opportunity Name",
                                            fieldName: "opportunityName",
                                            initialWidth: 200,
                                            type: "text",
                                            sortable: false,
                                        },
                                        {
                                            label: "Opportunity Stage",
                                            fieldName: "opportunityStage",
                                            type: "text",
                                            initialWidth: 200,
                                            sortable: false,
                                        },
                                    ];
                                        
                                        component.set("v.oppRecColum", oppColum);
                                        
                                        var action = component.get("c.getOppRecDetails");
                                        
                                        action.setParams({
                                        recId: event.getParam("recordId"),
                                        });
                                        
                                        action.setCallback(this, function (response) {
                                        if (response.getState() === "SUCCESS") {
                                        if (response.getReturnValue() != null) {
                                        if (response.getReturnValue().length != 0) {
                                        component.set("v.selectedOppRec", response.getReturnValue());
                                        component.set("v.showOppRecTable", true);
                                        } else {
                                        component.set("v.selectedOppRec", "");
                                        component.set("v.showOppRecTable", false);
                                        }
                                        } else {
                                        component.set("v.selectedOppRec", "");
                                        component.set("v.showOppRecTable", false);
                                        }
                                        } else if (response.getState() === "ERROR") {
                                        component.set("v.selectedOppRec", "");
                                        component.set("v.showOppRecTable", false);
                                        
                                        var errors = response.getError();
                                        console.error(errors);
                                        }
                                        });
                                        
                                        $A.enqueueAction(action);
                                        } //END OF ELSE
                                        }, //end of method
                                        
                                        handleNext: function (component, event, helper) {
                                        
                                        //as if there are some seleted rows( in draft values ) then it will save it.
                                        if( component.find("tableData").get("v.draftValues").length > 0 ){
                                        
                                        helper.handleSaveEditionHelp(component,event);
                                        }
                                        
                                        component.find("tableData").set("v.draftValues", null);
                                        
                                        var listSchoolRecord = component.get("v.ScheoolRecords");
                                        var strtPage = component.get("v.startPage");
                                        var endPage = component.get("v.endPage");
                                        var pageSize = component.get("v.pageSize");
                                        
                                        var listSchoolToShow = [];
                                    var recordCounter = 0;
                                    
                                    for( var index = endPage + 1; index < endPage + pageSize + 1; index ++ ){
                                        
                                        if( listSchoolRecord.length > index ){
                                            
                                            listSchoolToShow.push( listSchoolRecord[ index ]);
                                        }
                                        recordCounter ++;
                                    }
                                    console.log( listSchoolToShow );
                                    strtPage = strtPage + recordCounter;
                                    endPage = endPage + recordCounter;
                                    component.set("v.startPage", strtPage);
                                    component.set("v.endPage", endPage);
                                    component.set('v.ScheoolRecordsToShow', listSchoolToShow);
                                    
                                }, //end of handle next
                                    handlePrev: function (component, event) {
                                        
                                        //as if there are some seleted rows( in draft values ) then it will save it.
                                        if( component.find("tableData").get("v.draftValues").length > 0 ){
                                            
                                            helper.handleSaveEditionHelp(component,event);
                                        }
                                        component.find("tableData").set("v.draftValues", null);
                                        
                                        var listSchoolRecord = component.get("v.ScheoolRecords");
                                        var strtPage = component.get("v.startPage");
                                        var endPage = component.get("v.endPage");
                                        var pageSize = component.get("v.pageSize");
                                        
                                        var listSchoolToShow = [];
                                        var recordCounter = 0;
                                        
                                        for( var index = strtPage - pageSize; index < strtPage; index ++ ){
                                            
                                            if( index > -1 ){
                                                
                                                listSchoolToShow.push( listSchoolRecord[index]);
                                                recordCounter ++;
                                            }
                                            else{
                                                
                                                strtPage++;
                                            }
                                        }
                                        strtPage = strtPage - recordCounter;
                                        endPage = endPage - recordCounter;
                                        component.set("v.startPage", strtPage);
                                        component.set("v.endPage", endPage);
                                        component.set('v.ScheoolRecordsToShow', listSchoolToShow);
                                        
                                    },
                                        //this work if suppressBottomBar = false and click the save button
                                        //else helper one will work 
                                        handleSaveEdition: function(component,event){
                                            
                                            console.log( event.getParam("draftValues"));
                                            var listSchoolRecord = component.get("v.ScheoolRecordsToShow");
                                            var listSchoolRecordFull = component.get("v.ScheoolRecords");
                                            var params = event.getParam("draftValues");
                                            for (var f in params) {
                                                //console.log(f + ' = ' + params[f])
                                                //console.log(params[f].isChecked);
                                                //console.log(params[f].Id);
                                                var rowIndex = params[f].Id.replace('row-','');
                                                
                                                if( !isNaN(rowIndex) ){
                                                    
                                                    rowIndex = Number( rowIndex );
                                                    console.log( rowIndex )
                                                    console.log(listSchoolRecord[rowIndex].sNo);
                                                    // console.log(listSchoolRecord[rowIndex]);
                                                    listSchoolRecord[rowIndex].isChecked = params[f].isChecked;
                                                    //console.log( listSchoolRecordFull[listSchoolRecord[rowIndex].sNo] );
                                                    
                                                    console.log(listSchoolRecordFull[listSchoolRecord[rowIndex].sNo]);
                                                    listSchoolRecordFull[listSchoolRecord[rowIndex].sNo - 1].isChecked = params[f].isChecked;
                                                }
                                                
                                            }
                                            
                                            component.set('v.ScheoolRecordsToShow',listSchoolRecord);
                                            component.set('v.ScheoolRecords',listSchoolRecordFull);
                                            
                                            component.find("tableData").set("v.draftValues", null);
                                            
                                        },
                                            
                                            isSearchValueEnter: function( component, event, helper ){
                                                
                                                var searchvalue  = event.getSource().get("v.value");
                                                component.set("v.studentid","");
                                                
                                                if($A.util.isEmpty(searchvalue)){
                                                    
                                                    component.set('v.showOppRecTable',false);
                                                }
                                            },
                                                searchOpp: function( component, event, helper ){
                                                    
                                                    var searchKeyword = component.get('v.searchTerm');
                                                    component.set( "v.selectedOppRec","" );
                                                    
                                                    if( $A.util.isEmpty( searchKeyword ) ){
                                                        
                                                        component.set('v.showOppRecTable',false);
                                                        
                                                    }else{
                                                        
                                                        component.set("v.spinneristrueModal", true);
                                                        var oppColum = [];
                                                        oppColum = [
                                                            {
                                                                label: "",
                                                                fieldName: "",
                                                                initialWidth: 100,
                                                                type: "text",
                                                            },
                                                            {
                                                                label: "Student ID",
                                                                fieldName: "studentId",
                                                                initialWidth: 150,
                                                                type: "text",
                                                                sortable: false,
                                                            },
                                                            {
                                                                label: "Student Name",
                                                                fieldName: "studentName",
                                                                initialWidth: 200,
                                                                type: "text",
                                                                sortable: false,
                                                            },
                                                            {
                                                                label: "Opportunity Name",
                                                                fieldName: "opportunityName",
                                                                initialWidth: 200,
                                                                type: "text",
                                                                sortable: false,
                                                            },
                                                            {
                                                                label: "Opportunity Stage",
                                                                fieldName: "opportunityStage",
                                                                type: "text",
                                                                initialWidth: 230,
                                                                sortable: false,
                                                            },
                                                            {
                                                                label: "Opportunity Case Manager",
                                                                fieldName: "oppCaseManagerName",
                                                                type: "text",
                                                                initialWidth: 220,
                                                                sortable: false,
                                                            },
                                                        ];
                                                            
                                                            component.set("v.oppRecColum", oppColum);
                                                            
                                                            var action = component.get("c.getOppRecDetails");
                                                            
                                                            action.setParams({
                                                            searchKey: searchKeyword,
                                                            });
                                                            
                                                            action.setCallback(this, function (response) {
                                                            if (response.getState() === "SUCCESS") {
                                                            		
                                                            component.set("v.spinneristrueModal", false);
                                                            
                                                            	if (response.getReturnValue() != null) {
                                                            
                                                            		if (response.getReturnValue().length != 0) {
                                                            
                                                            			component.set("v.selectedOppRec", response.getReturnValue());
                                                            			component.set("v.showOppRecTable", true);
                                                            		}
                                                            		else {
                                                            			component.set("v.selectedOppRec", "");
                                                            			component.set("v.showOppRecTable", false);
                                                            		}
                                                            	} else {
                                                            			component.set("v.selectedOppRec", "");
                                                            			component.set("v.showOppRecTable", false);
                                                            		}
                                                            } else if (response.getState() === "ERROR") {
                                                            			
                                                            component.set("v.spinneristrueModal", false);
                                                            			component.set("v.selectedOppRec", "");
                                                            			component.set("v.showOppRecTable", false);
                                                            
                                                           				 var errors = response.getError();
                                                            			console.error(errors);
                                                            }
                                                            });
                                                            
                                                            $A.enqueueAction(action);
                                                    }
                                         },
                                         
                                                            getSelectedRecords: function( component, event, helper){
                                                            
																var selectedRows = event.getParam('selectedRows');
                                                           
                                                            if( selectedRows.length > 0 ){
                                                            
                                                            //as at a time only one record is being select
                                                            component.set("v.studentid",selectedRows[0].opportunityId);
                                                            }
                                                            
                                                        console.log(component.get("v.studentid"));
                                                            },
                                                            
                                                            
});