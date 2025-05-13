sap.ui.require(
    [
        'sap/fe/test/JourneyRunner',
        'ats/po/managepo/test/integration/FirstJourney',
		'ats/po/managepo/test/integration/pages/POsList',
		'ats/po/managepo/test/integration/pages/POsObjectPage',
		'ats/po/managepo/test/integration/pages/POItemsObjectPage'
    ],
    function(JourneyRunner, opaJourney, POsList, POsObjectPage, POItemsObjectPage) {
        'use strict';
        var JourneyRunner = new JourneyRunner({
            // start index.html in web folder
            launchUrl: sap.ui.require.toUrl('ats/po/managepo') + '/index.html'
        });

       
        JourneyRunner.run(
            {
                pages: { 
					onThePOsList: POsList,
					onThePOsObjectPage: POsObjectPage,
					onThePOItemsObjectPage: POItemsObjectPage
                }
            },
            opaJourney.run
        );
    }
);