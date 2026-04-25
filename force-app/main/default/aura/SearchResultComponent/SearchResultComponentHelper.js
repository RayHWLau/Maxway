({     
    sortData: function (component, fieldName, sortDirection) {
        
        var data = component.get("v.ScheoolRecords");
        //var data = component.get("v.ScheoolRecordsToShow");
        var reverse = sortDirection !== 'asc';
        
        //sorts the rows based on the column header that's clicked
        if(fieldName === 'SchoolId')
            fieldName = 'Name'  
            
            //thisis done as if some row doesnot have value in it (undefined) replace it with ''
            for( var index of data ){
                
                if( $A.util.isEmpty( index[fieldName ])){
                    index[fieldName] = '';
                }
                
            }
        data.sort(this.sortBy(fieldName, reverse))
        component.set("v.ScheoolRecords", data);
        //component.set("v.ScheoolRecordsToShow", data);
    },
    sortBy: function (field, reverse, primer) {
        
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    handleSaveEditionHelp: function(component,event){
        var listSchoolRecord = component.get("v.ScheoolRecordsToShow");
        var listSchoolRecordFull = component.get("v.ScheoolRecords");
        var params = component.find("tableData").get("v.draftValues");
        for (var f in params) {
            //console.log(f + ' = ' + params[f])
            //console.log(params[f].isChecked);
            //console.log(params[f].Id);
            console.log(params[f].Id);
            var rowIndex = params[f].Id.replace('row-','');
            
            if( !isNaN(rowIndex) ){
                
                rowIndex = Number( rowIndex );
                console.log( rowIndex )
                console.log(listSchoolRecord[rowIndex].sNo);
                // console.log(listSchoolRecord[rowIndex]);
                listSchoolRecord[rowIndex].isChecked = params[f].isChecked;
                //console.log( listSchoolRecordFull[listSchoolRecord[rowIndex].sNo] );
                
                console.log(listSchoolRecordFull[listSchoolRecord[rowIndex].sNo-1]);
                listSchoolRecordFull[listSchoolRecord[rowIndex].sNo - 1].isChecked = params[f].isChecked;
            }
            
        }
        
        component.set('v.ScheoolRecordsToShow',listSchoolRecord);
        component.set('v.ScheoolRecords',listSchoolRecordFull);
        
        component.find("tableData").set("v.draftValues", null);
        
    },
    handleNextHelp: function(component,event){
        
        var listSchoolRecord = component.get("v.ScheoolRecords");
        var strtPage = component.get("v.startPage");
        var endPage = component.get("v.endPage");
        var pageSize = component.get("v.pageSize");
        
        console.log( "strtPage  " + strtPage);
        console.log( "endPage  " + endPage);
        console.log( "pageSize  " +pageSize );
        
        var listSchoolToShow = [];
        var recordCounter = 0;
        
        for( var index = strtPage; index < strtPage + pageSize + 1; index ++ ){
            
            if( listSchoolRecord.length > index ){
                
                listSchoolToShow.push( listSchoolRecord[ index ]);
            }
            recordCounter ++;
        }
        console.log( listSchoolToShow );
        component.set('v.ScheoolRecordsToShow', listSchoolToShow);
    }
})