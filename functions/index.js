'use strict';

const admin = require('firebase-admin');
const functions = require('firebase-functions');
admin.initializeApp(functions.config().firebase);

/**
 * Triggers when a user gets a new follower and sends a notification.
 *
 * Followers add a flag to `/followers/{followedUid}/{followerUid}`.
 * Users save their device notification tokens to `/users/{followedUid}/notificationTokens/{notificationToken}`.
 */
exports.sendFollowerNotification = functions.database.ref('/user-followers/{followedUid}/{followerUid}').onWrite(event => {
	const followerUid = event.params.followerUid;
	const followedUid = event.params.followedUid;
  	// If un-follow we exit the function.
	if (!event.data.val()) {
		return console.log('User ', followerUid, 'un-followed user', followedUid);
  	}
  	console.log('We have a new follower UID:', followerUid, 'for user:', followerUid);

  	// Get the list of device notification tokens.
  	const getDeviceTokensPromise = admin.database().ref(`/user-notification-tokens/${followedUid}`).once('value');

  	// Get the follower profile.
  	const getFollowerProfilePromise = admin.auth().getUser(followerUid);

  	return Promise.all([getDeviceTokensPromise, getFollowerProfilePromise]).then(results => {
    	const tokensSnapshot = results[0];
    	const follower = results[1];

    	// Check if there are any device tokens.
    	if (!tokensSnapshot.hasChildren()) {
      		return console.log('There are no notification tokens to send to.');
    	}
    	console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.');
    	console.log('Fetched follower profile', follower);
		
		var url = ""
		
		if (follower.photoURL) {
			url = follower.photoURL
		}
		
    	// Notification details.
    	const payload = {
      		notification: {
        			title: 'You have a new follower!',
        			body: `${follower.displayName} is now following you.`,
        			icon: url,
        			sound: "default"
      		},
      		data: {
      			click_action: `profile ${followerUid}`
      		}
    	};

    	// Listing all tokens.
    	const tokens = Object.keys(tokensSnapshot.val());

    	// Send notifications to all tokens.
    	return admin.messaging().sendToDevice(tokens, payload).then(response => {
      		// For each message check if there was an error.
      		const tokensToRemove = [];
      		response.results.forEach((result, index) => {
        			const error = result.error;
        			if (error) {
          			console.error('Failure sending notification to', tokens[index], error);
          			// Cleanup the tokens who are not registered anymore.
          			if (error.code === 'messaging/invalid-registration-token' ||
              			error.code === 'messaging/registration-token-not-registered') {
            				tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
          			}
        			}
      		});
      		return Promise.all(tokensToRemove);
    	});
	});
});
/*
exports.sendAddedToGroupNotification = functions.database.ref('/user-groups/{addedUid}/{groupid}').onWrite(event => {
	const addedUid = event.params.addedUid;
	const groupid = event.params.groupid;
  	// If un-follow we exit the function.
	if (!event.data.val()) {
		return console.log('User ', addedUid, ' left group', groupid);
  	}
  	console.log('We have a new group ID:', groupid, 'for user:', addedUid);

  	// Get the list of device notification tokens.
  	const getDeviceTokensPromise = admin.database().ref(`/user-notification-tokens/${addedUid}`).once('value');

  	// Get the follower profile.
  	const getGroupPromise = admin.database().ref(`/groups/${groupid}`).once('value');

  	return Promise.all([getDeviceTokensPromise, getGroupPromise]).then(results => {
    	const tokensSnapshot = results[0];
    	const groupSnapshot = results[1];

    	// Check if there are any device tokens.
    	if (!tokensSnapshot.hasChildren()) {
      		return console.log('There are no notification tokens to send to.');
    	}
    	
    	if (!groupSnapshot.hasChildren()) {
    		return console.log('Invalid group');
    	}
    	
    	console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.');
    	console.log('Fetched group');
    	
    	const group = groupSnapshot.val();
    	
    	console.log(group['name']);
		
		var url = ""
		
		if (group["image-url"]) {
			url = group["image-url"]
		}
		
    	// Notification details.
    	const payload = {
      		notification: {
        			title: 'You have been added to a group!',
        			body: `You are now a part of ${group["name"]}`,
        			icon: url,
        			sound: "default"
      		},
      		data: {
      			click_action: `group ${groupid}`
      		}
    	};

    	// Listing all tokens.
    	const tokens = Object.keys(tokensSnapshot.val());

    	// Send notifications to all tokens.
    	return admin.messaging().sendToDevice(tokens, payload).then(response => {
      		// For each message check if there was an error.
      		const tokensToRemove = [];
      		response.results.forEach((result, index) => {
        			const error = result.error;
        			if (error) {
          			console.error('Failure sending notification to', tokens[index], error);
          			// Cleanup the tokens who are not registered anymore.
          			if (error.code === 'messaging/invalid-registration-token' ||
              			error.code === 'messaging/registration-token-not-registered') {
            				tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
          			}
        			}
      		});
      		return Promise.all(tokensToRemove);
    	});
	});
});

exports.sendJoinedYourGroupNotification = functions.database.ref('/user-groups/{joinedUid}/{groupid}').onWrite(event => {
    const joinedUid = event.params.joinedUid;
    const groupid = event.params.groupid;
    // If un-follow we exit the function.
    if (!event.data.val()) {
        return console.log('User ', joinedUid, ' left group', groupid);
    }
    console.log('We have a new group ID:', groupid, 'for user:', joinedUid);

    admin.database().ref(`/groups/${groupid}/owner-uid`).once('value', function(snap) {
        const ownerUid = snap.val();
  
  		console.log(`owner uid: ${ownerUid}`);
  		
        // Get the list of device notification tokens.
        const getDeviceTokensPromise = admin.database().ref(`/user-notification-tokens/${ownerUid}`).once('value');

        // Get the group
        const getGroupPromise = admin.database().ref(`/groups/${groupid}`).once('value');
      
        // get the profile of who joined
        const getJoinedProfilePromise = admin.auth().getUser(joinedUid);

        return Promise.all([getDeviceTokensPromise, getGroupPromise, getJoinedProfilePromise]).then(results => {
            const tokensSnapshot = results[0];
            const groupSnapshot = results[1];
            const joinedProfile = results[2];

            // Check if there are any device tokens.
            if (!tokensSnapshot.hasChildren()) {
                return console.log('There are no notification tokens to send to.');
            }
            
            if (!groupSnapshot.hasChildren()) {
              return console.log('Invalid group');
            }
            
            console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.');
            console.log('Fetched group');
            console.log('Fetched joined user', joinedProfile.displayName);
            
            const group = groupSnapshot.val()
          
            var url = ""
          
            if (joinedProfile.photoURL) {
                url = joinedProfile.photoURL
            }
          
            // Notification details.
            const payload = {
                notification: {
                  title: 'Your group has a new member!',
                  body: `${joinedProfile.displayName} has joined ${group["name"]}`,
                  icon: url,
                  sound: "default"
                },
      			data: {
      				click_action: `profile ${joinedUid}`
      			}
            };

            // Listing all tokens.
            const tokens = Object.keys(tokensSnapshot.val());

            // Send notifications to all tokens.
            return admin.messaging().sendToDevice(tokens, payload).then(response => {
                // For each message check if there was an error.
                const tokensToRemove = [];
                response.results.forEach((result, index) => {
                    const error = result.error;
                    if (error) {
                        console.error('Failure sending notification to', tokens[index], error);
                        // Cleanup the tokens who are not registered anymore.
                        if (error.code === 'messaging/invalid-registration-token' ||
                            error.code === 'messaging/registration-token-not-registered') {
                            tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
                        }
                    }
                });
                return Promise.all(tokensToRemove);
            });
        });
      
    });
});
*/
exports.sendGroupPendingRequestNotification = functions.database.ref('/pending-requests-for-users/{ownerUid}/{requestid}').onWrite(event => {
    const ownerUid = event.params.ownerUid;
    const requestid = event.params.requestid;

    if (!event.data.val()) {
        return console.log('deleted request');
    }
    console.log('We have a new pending request ID:', requestid, 'for user:', ownerUid);

    admin.database().ref(`/pending-requests/${requestid}`).once('value', function(snap) {
        const requestDict = snap.val();

        const fromUid = requestDict['from-uid']
        const groupid = requestDict['gid']
  
  		console.log(`from uid: ${fromUid}`);
        console.log(`group id: ${groupid}`);
  		
        // Get the list of device notification tokens.
        const getDeviceTokensPromise = admin.database().ref(`/user-notification-tokens/${ownerUid}`).once('value');

        // Get the group
        const getGroupPromise = admin.database().ref(`/groups/${groupid}`).once('value');
      
        // get the profile of who joined
        const getRequestingProfilePromise = admin.auth().getUser(fromUid);

        return Promise.all([getDeviceTokensPromise, getGroupPromise, getRequestingProfilePromise]).then(results => {
            const tokensSnapshot = results[0];
            const groupSnapshot = results[1];
            const requestingProfile = results[2];

            // Check if there are any device tokens.
            if (!tokensSnapshot.hasChildren()) {
                return console.log('There are no notification tokens to send to.');
            }
            
            if (!groupSnapshot.hasChildren()) {
                return console.log('Invalid group');
            }
            
            console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.');
            console.log('Fetched group');
            console.log('Fetched requesting user', requestingProfile.displayName);
            
            const group = groupSnapshot.val()
          
            var url = ""
          
            if (requestingProfile.photoURL) {
                url = requestingProfile.photoURL
            }
          
            // Notification details.
            const payload = {
                notification: {
                  title: 'Someone has requested to join your group!',
                  body: `${requestingProfile.displayName} would like to join ${group['name']}`,
                  icon: url,
                  sound: "default"
                },
      			data: {
      				click_action: `request ${fromUid}`
      			}
            };

            // Listing all tokens.
            const tokens = Object.keys(tokensSnapshot.val());

            // Send notifications to all tokens.
            return admin.messaging().sendToDevice(tokens, payload).then(response => {
                // For each message check if there was an error.
                const tokensToRemove = [];
                response.results.forEach((result, index) => {
                    const error = result.error;
                    if (error) {
                        console.error('Failure sending notification to', tokens[index], error);
                        // Cleanup the tokens who are not registered anymore.
                        if (error.code === 'messaging/invalid-registration-token' ||
                            error.code === 'messaging/registration-token-not-registered') {
                            tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
                        }
                    }
                });
                return Promise.all(tokensToRemove);
            });
        });
      
    });
});

exports.sendEventInvitationNotification = functions.database.ref('/user-event-invitations/{invitedUid}/{invitationID}').onWrite(event => {
    const invitedUid = event.params.invitedUid;
    const invitationID = event.params.invitationID;

    admin.database().ref(`/event-invitations/${invitationID}`).once('value', function(snap) {
        const requestDict = snap.val();

        const fromUid = requestDict['from-uid']
        const eid = requestDict['eid']
        
        // Get the list of device notification tokens.
        const getDeviceTokensPromise = admin.database().ref(`/user-notification-tokens/${invitedUid}`).once('value');

        // Get the group
        const getEventPromise = admin.database().ref(`/events/${eid}`).once('value');
      
        // get the profile of who joined
        const getInvitingProfilePromise = admin.auth().getUser(fromUid);

        return Promise.all([getDeviceTokensPromise, getEventPromise, getInvitingProfilePromise]).then(results => {
            const tokensSnapshot = results[0];
            const eventSnapshot = results[1];
            const invitingProfile = results[2];
            
            const event = eventSnapshot.val()
          
            var url = ""
          
            if (invitingProfile.photoURL) {
                url = invitingProfile.photoURL
            }
          
            // Notification details.
            const payload = {
                notification: {
                    title: 'You have been invited to an event!',
                    body: `${invitingProfile.displayName} has invited you to attend ${event['title']}`,
                    icon: url,
                    sound: "default"
                },
                data: {
                    click_action: `invitation ${eid}`
                }
            };

            // Listing all tokens.
            const tokens = Object.keys(tokensSnapshot.val());

            // Send notifications to all tokens.
            return admin.messaging().sendToDevice(tokens, payload).then(response => {
                // For each message check if there was an error.
                const tokensToRemove = [];
                response.results.forEach((result, index) => {
                    const error = result.error;
                    if (error) {
                        console.error('Failure sending notification to', tokens[index], error);
                        // Cleanup the tokens who are not registered anymore.
                        if (error.code === 'messaging/invalid-registration-token' ||
                            error.code === 'messaging/registration-token-not-registered') {
                            tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
                        }
                    }
                });
                return Promise.all(tokensToRemove);
            });
        });
      
    });
})