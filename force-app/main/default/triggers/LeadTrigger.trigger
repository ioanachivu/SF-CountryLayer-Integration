/**
 * @description       : 
 * @author            : ioana-a-chivu
 * @group             : 
 * @last modified on  : 11-11-2024
 * @last modified by  : ioana-a-chivu
**/
trigger LeadTrigger on Lead (before insert, before update) {
    if (Trigger.isBefore) {
        LeadHandler.populateLeadCountryInfo(Trigger.new);
    }
}
