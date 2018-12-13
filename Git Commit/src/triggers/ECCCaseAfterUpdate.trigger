trigger ECCCaseAfterUpdate on Case (After Update) {
    for(Case newCase : Trigger.new) {
        Case oldCase = Trigger.oldMap.get(newCase.Id);
        if (newCase.OwnerId != oldCase.OwnerId) {
            System.Debug('New Case Owner does not equal to Old Case Owner');
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MentionSegmentInput mentionSegmentInput;
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

            textSegmentInput.text = UserInfo.getName() + ' assigned case to ';

            messageBodyInput.messageSegments.add(textSegmentInput);

            if (((Id)newCase.OwnerId).getSObjectType() == Schema.User.SObjectType) {
                mentionSegmentInput = new ConnectApi.MentionSegmentInput(); 
                mentionSegmentInput.id = newCase.OwnerId;
                messageBodyInput.messageSegments.add(mentionSegmentInput);
            }
            else {
                Set<Id> gms = ECCUtil.GetUserIdsFromGroup(newCase.OwnerId);
                //List<GroupMember> gms = [select UserOrGroupId from GroupMember where GroupId = :newCase.OwnerId];
                Boolean addComma = false;

                for (Id gm : gms) {
                    if (addComma) {
                        textSegmentInput = new ConnectApi.TextSegmentInput();
                        textSegmentInput.text = ', ';
                        messageBodyInput.messageSegments.add(textSegmentInput);
                    }

                    mentionSegmentInput = new ConnectApi.MentionSegmentInput(); 
                    mentionSegmentInput.id = gm;
                    messageBodyInput.messageSegments.add(mentionSegmentInput);              

                    addComma = true;
                }
            }

            feedItemInput.body = messageBodyInput;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = newCase.Id;

            ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInput, null);
        }
    }
}