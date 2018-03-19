public with sharing class TestDataFactory_Products {
	public static List<Product2> generateProducts(String name, String role) {
		return generateProductsInternal(name, role);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Product2> generateProductsInternal(String name, String role) {
    	List<Product2> productList = new List<Product2>();
        
            Product2 productRec = new Product2();
            productRec.Name = name;
            productRec.Role__c = role;
            productList.add(productRec);
        
        return productList;
    }  
}