/**
 * @description       : 
 * @author            : ioana-a-chivu
 * @group             : 
 * @last modified on  : 09-16-2024
 * @last modified by  : ioana-a-chivu
**/
trigger NN_LeadTrigger on Lead (before insert, before update) {
    if (Trigger.isBefore) {
        NN_LeadHandler.populateLeadCountryInfo(Trigger.new);
    }
}
