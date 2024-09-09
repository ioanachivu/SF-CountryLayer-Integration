/**
 * @description       : 
 * @author            : ioana-a-chivu
 * @group             : 
 * @last modified on  : 09-07-2024
 * @last modified by  : ioana-a-chivu
**/
trigger NN_LeadTrigger on Lead (before insert, before update) {
    if (Trigger.isBefore) {
        LeadHelper.populateCountryInfo(Trigger.new);
    }
}
