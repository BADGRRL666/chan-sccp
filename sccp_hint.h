/*
 * sccp_hint.h
 *
 *  Created on: 16.01.2009
 *      Author: marcello
 */

#ifndef SCCP_HINT_H_
#define SCCP_HINT_H_

#include "asterisk.h"
#include "chan_sccp.h"

typedef enum{ASTERISK=0, INTERNAL=1} sccp_hinttype_t;
//#define SCCP_HINTSTATE_NOTINUSE	0
//#define SCCP_HINTSTATE_INUSE		1



typedef struct sccp_hint_SubscribingDevice sccp_hint_SubscribingDevice_t;
struct sccp_hint_SubscribingDevice{

	const sccp_device_t	*device;
	uint8_t				instance;

	SCCP_LIST_ENTRY(sccp_hint_SubscribingDevice_t) list;
};

/**
 * we hold a mailbox event subscription in sccp_mailbox_subscription_t.
 *
 * Each line that holds a subscription for this mailbox is listed in
 */
typedef struct sccp_hint_list sccp_hint_list_t;
struct sccp_hint_list{
	ast_mutex_t lock;
  
	char exten[AST_MAX_EXTENSION];			/*!< extension for hint */
	char context[AST_MAX_CONTEXT];			/*!< context for hint */
	char hint_dialplan[256];				/*!< e.g. IAX2/station123 */

	sccp_channelState_t currentState;
	sccp_hinttype_t		hintType;

	struct{
		char callingPartyName[StationMaxNameSize];
		char calledPartyName[StationMaxNameSize];
		char callingParty[StationMaxNameSize];
		char calledParty[StationMaxNameSize];
		
		skinny_calltype_t calltype;
	}callInfo;



	union sccp_hint_type{
		struct{
			char 		lineName[AST_MAX_EXTENSION];
		} internal;

		struct{
			int			hintid;
			pthread_t 		notificationThread;	
		} asterisk;
	} type;

	SCCP_LIST_HEAD(, sccp_hint_SubscribingDevice_t) subscribers;
	SCCP_LIST_ENTRY(sccp_hint_list_t) list;
};


SCCP_LIST_HEAD(, sccp_hint_list_t) sccp_hint_subscriptions;


/**
 * activate hint for device
 * \param d device
 */
int sccp_hint_state(char *context, char* exten, enum ast_extension_states state, void *data);
void sccp_hint_lineStatusChanged(sccp_line_t *line, sccp_device_t *device, sccp_channel_t *channel, sccp_channelState_t previousState, sccp_channelState_t newState);
void sccp_hint_module_start(void);
void sccp_hint_module_stop(void);



#endif /* SCCP_HINT_H_ */
