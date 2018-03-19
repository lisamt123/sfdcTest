({
	showErrorMessage : function(component,response) {
        var errors = response.getError();
        if (errors) {
            errors.forEach( function (error) {

                if (error.message) {
                    console.log(error.message);                    
                }

                if (error.pageErrors) {
                    error.pageErrors.forEach( function(pageError) {
                        console.log(pageError.message);                  
                    });                 
                }

                if (error.fieldErrors) {
                    for (var fieldName in error.fieldErrors) {
                        error.fieldErrors[fieldName].forEach( function (errorList) { 
                            console.log(errorList.message + " Field Error on " + fieldName + " : ");                        
                        });                                
                    };                   
                } 
            }); 
        }
    },
})