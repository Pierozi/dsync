SHELL := /bin/bash

sshUser         := user
sshKey          := /home/user/.ssh/id_dsa
sshRemote       := domain.tld
PathRemoteBase  := /where/you/want

GREEN 	:= "\\033[1;32m"
NORMAL	:= "\\033[0;39m"
RED	:= "\\033[1;31m"
PINK	:= "\\033[1;35m"
BLUE	:= "\\033[1;34m"
WHITE	:= "\\033[0;02m"
YELLOW	:= "\\033[1;33m"
CYAN	:= "\\033[1;36m"

Path  	  	= $(shell echo $@ | sed -e 's/pull\///' -e 's/push\///' -e 's/dstime\///' -e 's/tinfo\///' -e 's/clone\///')
PathLocal	= $(Path)
PathRemote	= $(PathRemoteBase)/$(Path)
llctime		= $(shell find $(PathLocal) | xargs -I FD stat -c%Y FD | sort -ur | head -n 1)
pushtime	= $(shell cat $(PathLocal)/.dsynctime)
time		= $(shell echo $$((`date +%s`-100)))
remoteTime	= $(shell ssh $(sshUser)@$(sshRemote) 'cat $(PathRemote)/.dsynctime')
dsyncignore	= $(shell test -s $(PathLocal)/.dsyncignore && cat $(PathLocal)/.dsyncignore | awk '{ print "--exclude ""\""$$1"\""""}')


.PHONY: clone pull push dstime tinfo


clone/%:
	@if [ ! -d "$(PathLocal)" ];then                                               \
                echo -e $(GREEN)"Clone git repository : "$(RED)$(repo)$(BLUE);          \
                git clone $(repo) $(PathLocal);                                        \
                                                                                        \
                echo -e $(GREEN)"\nProject created on "$(RED)$(PathLocal);             \
                echo -e $(GREEN)"Create dsynctime file...";                             \
                echo "$(time)" > $(PathLocal)/.dsynctime;                              \
                                                                                        \
                echo -e $(GREEN)"\nDone with success !";                                \
        else                                                                            \
                echo -e $(RED)"This project already exist.\nYou probably want do make pull/$(PathLocal)";      \
        fi
	@tput sgr0;

pull/%:
	@if [ ! -d "$(PathLocal)" ];then						\
		echo -e $(GREEN)"Create project...";					\
		mkdir -p $(PathLocal);							\
		echo -e "Create path :" $(RED)$(PathLocal);				\
		echo -e $(BLUE);							\
											\
		rsync -azv --delete 							\
			-e "ssh -i $(sshKey) -l $(sshUser)" 				\
			--stats --human-readable $(sshRemote):$(PathRemote)/ $(PathLocal); 		\
											\
		tput sgr0;								\
		if [ ! -f "$(PathLocal)/.dsynctime" ];then                            	\
			echo -e $(GREEN)"Create dsynctime file...";			\
			echo "$(time)" > $(PathLocal)/.dsynctime;	                \
			tput sgr0;							\
                fi									\
	else										\
		echo -e $(CYAN)"Update project...";					\
		echo -e "Compare dsynctime...";						\
											\
		if [ "$(llctime)" -gt "$(remoteTime)" ] && [ "${force}" = "" ];then	\
			echo -e $(RED)"Danger ! Your local sync are most recent !";	\
			date "+Locale time : %d/%m/%Y %H:%M:%S" --date='@$(llctime)';	\
			date "+Server time : %d/%m/%Y %H:%M:%S" --date='@$(remoteTime)';	\
			echo -e "May you should Push ? check your devices... ;)\n"; 	\
			echo -e $(BLUE)"If you want force pull, run following command : \npull/$(Path) force=1\n"; \
			tput sgr0;							\
		else									\
			echo -e $(BLUE)"Pull project...";				\
											\
			rsync -azv --delete                                             \
                        	-e "ssh -i $(sshKey) -l $(sshUser)"                     \
                        	--stats --human-readable $(sshRemote):$(PathRemote)/ $(PathLocal);	\
											\
			echo -e $(GREEN)"\nDone with success !";			\
		fi									\
        fi
	@tput sgr0

push/%:
	@tput sgr0
	@if [ ! -d "$(PathLocal)" ];then						\
		echo -e $(RED)"Unable to find $(PathLocal): Project doesn't exist.";	\
		tput sgr0;								\
		exit 2;									\
	fi
	@if [ "$(remoteTime)" -gt "$(pushtime)" ] && [ "${force}" = "" ];then					\
		echo -e $(RED)"Danger ! distant sync are most recent !";		\
		echo -e $(BLUE)"If you want force push, run the following command : \npush/$(Path) force=1\n"; \
	else										\
		echo -e $(GREEN)"Update dsynctime...";					\
		echo "`date +%s`" > $(PathLocal)/.dsynctime;				\
		echo -e $(BLUE)"Push project...";					\
											\
		ssh $(sshUser)@$(sshRemote) mkdir -p $(PathRemote);			\
											\
		rsync -azv	                                            	 	\
			--delete --stats --human-readable $(dsyncignore)		\
                	-e "ssh -i $(sshKey) -l $(sshUser)"                    	 	\
			$(PathLocal)/ $(sshRemote):$(PathRemote);   			\
                                                                                        \
                        echo -e $(GREEN)"\nDone with success !";                        \
	fi
	@tput sgr0;

dstime/%:
	date +%s > $(PathLocal)/.dsynctime

tinfo/%:
	@if [ "1" -gt "0" ];then \
		date "+Locale time  : %d/%m/%Y %H:%M:%S" --date='@$(llctime)'; \
		date "+Push time    : %d/%m/%Y %H:%M:%S" --date='@$(pushtime)'; \
		date "+Distant time : %d/%m/%Y %H:%M:%S" --date='@$(remoteTime)'; \
	fi
