@isTest
public class BudgetControllerTest {
    
    @testSetup
static void setupTestData() {
    // Create test User
    User testUser = new User(
        FirstName = 'Test',
        LastName = 'User',
        Email = 'testuser@example.com',
        Username = 'mytestuser@example.com.test',
        Alias = 'tuser',
        TimeZoneSidKey = 'America/New_York',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
        LanguageLocaleKey = 'en_US'
    );
    insert testUser;

    // Create Income Sources
    List<Income_Source__c> incomeSources = new List<Income_Source__c>{
        new Income_Source__c(
            User__c = testUser.Id,
            Income_Amount__c = 1200,
            Income_Frequency__c = 'Monthly',
            Income_Name__c = 'Salary',
            Income_Type__c = 'Primary Income'
        ),
        new Income_Source__c(
            User__c = testUser.Id,
            Income_Amount__c = 3600,
            Income_Frequency__c = 'Quarterly',
            Income_Name__c = 'Bonus',
            Income_Type__c = 'Secondary Income'
        )
    };
    insert incomeSources;

    // Create Recurring Expenses
    List<Recurring_Expense__c> recurringExpenses = new List<Recurring_Expense__c>{
        new Recurring_Expense__c(
            User__c = testUser.Id,
            Expense_Amount__c = 500,
            Expense_Frequency__c = 'Monthly',
            Expense_Type__c = 'Fixed',
            Expense_Name__c = 'Rent'
        ),
        new Recurring_Expense__c(
            User__c = testUser.Id,
            Expense_Amount__c = 100,
            Expense_Frequency__c = 'Monthly',
            Expense_Type__c = 'Variable',
            Expense_Name__c = 'Utilities'
        )
    };
    insert recurringExpenses;

    // Create Savings/Checking Accounts
    List<Savings_Checking_Account__c> accounts = new List<Savings_Checking_Account__c>{
        new Savings_Checking_Account__c(
            User__c = testUser.Id,
            Balance__c = 5000,
            Monthly_Contribution__c = 100,
            Account_Type__c = 'Savings',
            Account_Name__c = 'Savings Account'
        ),
        new Savings_Checking_Account__c(
            User__c = testUser.Id,
            Balance__c = 2000,
            Monthly_Contribution__c = 50,
            Account_Type__c = 'Checking',
            Account_Name__c = 'Checking Account'
        )
    };
    insert accounts;
}

    @isTest
    static void testGetBudgetData() {
        // Get the test user
        User testUser = [SELECT Id FROM User WHERE Username = 'mytestuser@example.com.test' LIMIT 1];
        
        // Call the method
        Test.startTest();
        BudgetController.BudgetData budgetData = BudgetController.getBudgetData(testUser.Id);
        Test.stopTest();

        // Assertions
        System.assertEquals(2250, budgetData.totalMonthlyIncome, 'Total Monthly Income is incorrect');
        System.assertEquals(500, budgetData.totalFixedExpenses, 'Total Fixed Expenses are incorrect');
        System.assertEquals(100, budgetData.totalVariableExpenses, 'Total Variable Expenses are incorrect');
        System.assertEquals(0, budgetData.totalOneTimeExpenses, 'Total One-Time Expenses are incorrect');
        System.assertEquals(150, budgetData.totalMonthlyContributions, 'Total Monthly Contributions are incorrect');
        System.assertEquals(5000, budgetData.totalSavingsBalance, 'Total Savings Balance is incorrect');
        System.assertEquals(2000, budgetData.totalCheckingBalance, 'Total Checking Balance is incorrect');
    }

    @isTest
    static void testCreateOrUpdateMonthlyRecords() {
        // Call the method to create monthly records
        Test.startTest();
        BudgetController.createOrUpdateMonthlyRecords(2024, 1500, 500, 100, 0, 900);
        Test.stopTest();

        // Verify the records were created
        List<Monthly_Record__c> monthlyRecords = [SELECT Id, Name FROM Monthly_Record__c WHERE Year__c = 2024];
        System.assertEquals(12, monthlyRecords.size(), 'Monthly records not created correctly');
    }

    @isTest
    static void testUpdateMonthlyRecord() {
        // Create a test Monthly Record
        Monthly_Record__c record = new Monthly_Record__c(
            Name = 'Jan 2024',
            Month__c = 'Jan',
            Year__c = 2024,
            Income__c = 1500,
            Fixed_Expenses__c = 500
        );
        insert record;

        // Update the record
        record.Fixed_Expenses__c = 600;
        Test.startTest();
        BudgetController.updateMonthlyRecord(record);
        Test.stopTest();

        // Verify the update
        Monthly_Record__c updatedRecord = [SELECT Fixed_Expenses__c FROM Monthly_Record__c WHERE Id = :record.Id];
        System.assertEquals(600, updatedRecord.Fixed_Expenses__c, 'Monthly Record was not updated correctly');
    }

    @isTest
    static void testGetRecords() {
        // Call the method
        Test.startTest();
        List<sObject> incomeRecords = BudgetController.getRecords('Income_Source__c');
        Test.stopTest();

        // Assertions
        System.assertEquals(2, incomeRecords.size(), 'Income records not fetched correctly');
    }
}
