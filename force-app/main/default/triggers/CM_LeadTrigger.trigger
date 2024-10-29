/**
 * @description       : 
 * @author            : ioana-a-chivu
 * @group             : 
 * @last modified on  : 10-29-2024
 * @last modified by  : ioana-a-chivu
**/
trigger CM_LeadTrigger on Lead (before insert, before update) {
    if (Trigger.isBefore) {
        CM_LeadHandler.populateLeadCountryInfo(Trigger.new);
    }
}
