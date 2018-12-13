global class DialerStatusReportSched implements Schedulable{
    global void execute(SchedulableContext sc) {
    	List<ReportUtil.DialerStatusModel> model = ReportUtil.GetDialerStatusReportData();

    	if (model.size() > 0)
    	{
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = new String[] {'john.kirkpatrick.contractor@stjude.org'}; 
			String[] ccAddresses = new String[] {'john.kirkpatrick@stjude.org'};

			// Assign the addresses for the To and CC lists to the mail object.
			mail.setToAddresses(toAddresses);
			mail.setCcAddresses(ccAddresses);

			// Specify the address used when the recipients reply to the email. 
			mail.setReplyTo('donotreply@stjude.org');

			// Specify the name used as the display name.
			mail.setSenderDisplayName('Dialer Status Daily Report');

			// Specify the subject line for your email address.
			mail.setSubject('Dialer Status Daily Report');

			// Set to True if you want to BCC yourself on the email.
			mail.setBccSender(false);

			String body = '<style>table, th, tr, td { border: 1px solid black; border-spacing: 0px !important; } td, th { padding: 5px; }</style>';
			body += '<h3>Dialer Status Daily Report</h3><br/>';
			body += '<table><thead><tr>';
            body += '<th>Campaign</th>';
            body += '<th>Ready</th>';
            body += '<th>Checked Out</th>';
            body += '<th>Checked In</th>';
            body += '<th>Not Ready</th>';
            body += '<th>Failed</th>';
            body += '<th>Bad Phone</th>';
            body += '<th>Total</th>';
            body += '</tr></thead><tbody>';

            for (ReportUtil.DialerStatusModel m: model)
            {
            	system.debug('m.CampaignId' + m.CurrentCampaignId);
            	body += '<tr>';
            	body += '<td><a href=' + System.Url.getSalesforceBaseURL().toExternalForm() + '/' + m.CurrentCampaignId +'>' + m.CampaignName + '</a></td>';
				body += '<td>' + m.ReadyCount + '</td>';
				body += '<td>' + m.CheckedOutCount + '</td>';
				body += '<td>' + m.CheckedInCount + '</td>';
				body += '<td>' + m.NotReadyCount + '</td>';
				body += '<td>' + m.FailCount + '</td>';
				body += '<td>' + m.BadPhoneCount + '</td>';
				body += '<td>' + m.TotalCount + '</td>';
            	body += '</tr>';
            }
            body += '</tbody></table>';
			mail.setHtmlBody(body);

			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    	}
    }
}