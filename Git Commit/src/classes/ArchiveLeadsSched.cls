global class ArchiveLeadsSched implements Schedulable {
    global void execute(SchedulableContext sc) {
        List<Campaign> camplst =[
            SELECT Id, Name, ArchiveDestination__c, isArchivable__c
            FROM Campaign
            WHERE IsArchivable__c = true //get Archivable campaigns
                AND ArchiveDestination__c != null  //who have an archive destination
        ];
        for (Campaign c : camplst){
            System.debug('c.id : ' + c.id);
            ArchiveLeadsBat b = new ArchiveLeadsBat(c);
            database.executebatch(b, 15);
        }
    }
}