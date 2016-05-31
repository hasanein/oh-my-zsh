# Include aliases file created by the marker script
if [ -f ~/.marker_functions ] ; then	
	source ~/.marker_functions
fi

# #####################################################################################################################################################
# # 							                       SCRIPTS INCLUDE SECTION                 		            									 ##
# #####################################################################################################################################################


# MASABI-RELATED CUSTOMIZATION SCRIPTS - HOT FOLDER
for file in $(ls ~/bin/shell_customization_scripts/*.sh)
do
	. ${file}
done

# re-start ssh agent if it's not running - needed to connect to masabi bastion servers
eval $(ssh-agent) > /dev/null 2>&1
ssh-add > /dev/null 2>&1

# ######################################################################################################################################################
# ## 							                       PATH ENVIRONMENT VARIABLE SETUP                             								   	##
# ######################################################################################################################################################

OPT_BINARIES=/Users/joseph/opt/gradle-2.3/bin:/Users/joseph/opt/groovy-2.4.3/bin

export PATH=${OPT_BINARIES}:/usr/local/Cellar/bison/3.0.2/bin:${PATH}:/Users/joseph/opt/vault-cli-2.4.40/bin:/usr/libexec:/usr/local/mysql/bin:/Users/khafaji/bin:/Users/joseph/opt/BookmarkerScript:~/bin:/Users/joseph/opt/gradle-1.12/bin:/Users/joseph/opt/jq/bin:/Users/joseph/opt/sonar-runner-2.4/bin

# Yokadi ToDo list
export PATH=${PATH}:/Users/joseph/Projects/yokadi/bin

# Setting PATH for Python 3.4
# The orginal version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.4/bin:${PATH}"
export PATH

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

# Add Go workspace bin to PATH
export PATH=${PATH}:/Users/joseph/Projects/LearnGo/bin

# ######################################################################################################################################################
# ## 							                       COMMON VARIABLES export                 		            										##
# ######################################################################################################################################################

export MAVEN_OPTS="-Xmx1024M -XX:MaxPermSize=1024m"
export CATALINA_HOME="/Users/joseph/opt/apache-tomcat-7.0.64"
export JAVA_HOME=$(java_home -v 1.8)


# Go programming
export GOPATH=/Users/joseph/Projects/LearnGo


# MASABI
export MASABI_SVN="https://svn.masabi.com/svn/"

export GRADLE_HOME=/usr/local/Cellar/gradle/2.7


# ######################################################################################################################################################
# ## 							                                    COMMON ALIASES    	                 		            							##
# ######################################################################################################################################################
set -o vi

alias r="fc -e -"
alias o="open"
alias chrome="open -a \"Google Chrome\""
alias ll="ls -ltrG"
alias ls="ls -G"
alias tw="open -a TextWrangler"
alias preview="open -a preview"
alias cls="clear"
alias chrome="open -a Google Chrome"
alias xcode="open -a xcode"
alias sl="open -a Sublime\ Text.app"

# Git-related aliases
alias gitlog='git log --pretty=format:"%H: %Cred %an - %Cgreen %ad - %Cblue %s"'
alias st="git st"
alias br="git br | grep '*' | sed 's/*//g' | sed 's/ //g'"


alias vi="vim"

alias c="pbcopy"
alias p="pbpaste"

alias killAllApps="ps -ef | grep /Applications | grep -v grep | grep -vi iterm | awk '{print $2}' | xargs kill -9"
alias jd="open -a JD-GUI"

alias prof="sl ~/.zshrc"
alias plugin="sl /Users/joseph/.oh-my-zsh/plugins/jo-shell-customization/jo-shell-customization.plugin.zsh"
alias tempscript="touch ~/tmp/tmp.sh && sl ~/tmp/tmp.sh"

alias todo="yokadi"

eval $(boot2docker shellinit 2> /dev/null)

# ######################################################################################################################################################
# ## 							                                    COMMON FUNCTIONS    	                 		            						##
# ######################################################################################################################################################

function mark()
{
	markme $*
	. ~/.zshrc
}

function umark()
{
	umarkme $*
	unset $*
}

function gitit
{
	# Add the untracked file to git
	git add -A .
	# Commit the changes
	git commit -m "$1"
	# merge with the master branch on github
	git push -u origin master
}

function scgrep()
{
	for sourceCodeFile in $(find . -type f | grep -v svn | grep Procedure)
	do
		grep -il $1 ${sourceCodeFile}
	done | grep -v $1
}

function nkill()
{
	# consider switching to use pkill instead of re-inveting the wheel here.
	for pid in $(ps -ef | grep -i $1 | grep -v grep | awk '{print $2}')
	do
		echo "Terminating ${pid}..."
		kill -15 $pid
	done
}

function svn_commit()
{
	svn st
	svnAddAll
	svn commit -m "$1"
}

function dumpJcrAt()
{
	vlt --credentials admin:admin co http://localhost:4502/crx/-/jcr:root${1}
}

function generateSurefireReport()
{	
	for file in *.xml
		do echo "${file}: $(cat ${file} | grep '<testsuite fail' | awk -F "errors" '{print $1}' | cut -d "=" -f3)" 
	done | sort -t '"' -k 2.1nr | awk '{print $2}' | sed 's/"//g' | awk 'START{x=0} {x+=$1} END{print "\nTests execution time: " x/60" min\n"}'
}

function svnAddAll()
{
	svn st | grep ^? | awk '{print $2}' | xargs svn add
}

function commit()
{
	git add -A
	git commit -a
}

function svnDeleteAll()
{
  svn st | grep ^!  | awk '{print $2}' | xargs svn delete
}

# Here is a function that retrieves all the JARs that are available on Adobe CQ classpath
# for later de-compilation and further examination to develop an understanding of how Adobe CQ works internally.
function downloadAdobeCQJars()
{
	[ -z "$CRX_URL" ] && CRX_URL="http://vmd-mini-auth.emea.akqa.local:4502"
	[ -z "$CRX_CREDENTIALS" ] && CRX_CREDENTIALS="admin:admin"

	# Get the CRX classpath and save it into a file for later processing
	curl -H x-crxde-version:1.0 -H x-crxde-os:mac -H x-crxde-profile:default -u $CRX_CREDENTIALS $CRX_URL/bin/crxde.classpath.xml > .classpath 2> /dev/null	
	FILELIST=$(cat .classpath | sed -n '/lib/s/.*WebContent\(.*\)\".*/\1/p')
	
	# download all the jars
	for FILE in $FILELIST
	do
		echo "downloading $FILE ..."
		curl -u $CRX_CREDENTIALS ${CRX_URL}${FILE} -O 2> /dev/null
	done

	# remove the temp files
	rm -fr .classpath
}

function reOpenAllTunnels()
{
	nkill ssh

	. ~/bin/openTunnels.sh

	openAllTunnels $1
}

function getGitBranchName()
{
	OPEN_PARENTHESES="("
	CLOSE_PARENTHESES=")"
		
	if weHaveATag
		then			
			CURRENT_BRANCH="$(git branch 2> /dev/null | grep '^*' | awk '{print $4}' | sed 's/)//g')"
		else								
			CURRENT_BRANCH=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')						
	fi
	[ ! -z ${CURRENT_BRANCH} ] && echo "${OPEN_PARENTHESES}${CURRENT_BRANCH}${CLOSE_PARENTHESES} "
}

function weHaveATag()
{
	git branch 2> /dev/null | grep "detached from" > /dev/null	
	return $?
}	

function toggleGitBranchInPrompt
{
	echo ${PS1} | grep getGitBranchName &> /dev/null
	if ( test $? -eq "0")
	then
		export PS1=$(echo ${PS1} | sed "s/${GIT_BRANCH_NAME}//g")
	else
		export PS1=$(echo ${PS1} | sed "s_\(\\\$\)_${GIT_BRANCH_NAME}\1_")
	fi
}

function t()
{
	SEARCH_WORD=$(echo $1 | tr '[:upper:]' '[:lower:]')
	open -a /Applications/Google\ Chrome.app/ http://dictionary.cambridge.org/dictionary/british/${SEARCH_WORD}
}

function reload()
{
	. ~/.zshrc
	cd - &> /dev/null
    figlet -f roman "Profile reloaded"
    cd -
}

function deleteAllDockerImages()
{
	for imageID in $(docker images | awk '{print $3}' | grep -v IMAGE)
	do 
		docker rmi --force ${imageID}
	done
}

function readlink()
{
	echo $@
}

function sendAlertToMpgHipchat()
{
  curl -X POST --header "content-type: application/json" "http://api.hipchat.com/v2/room/MPG-LOGGLY-ALERTS/notification?auth_token=UrxxngPc9UMO0Jq5ZOe6SuPnsNKgRqDLQsvYiXW7" --data '{"message":"$1"}'
}

function prCreatedAlert()
{
	PR_TITLE="${2}"
	PR_TEXT="<${1}|Click here> to start the peer code review of this awesome code!"
	DATA=`echo {\"channel\": \"#payments\", \"username\": \"${PR_TITLE}\", \"text\": \"${PR_TEXT}\", \"icon_emoji\": \":monkey:\"}`
	curl -X POST --data "$DATA"  https://hooks.slack.com/services/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  
}

function createPullRequest()
{	
    PULL_REQUEST_URL=$(stash pull-request ${1} ${2} @alexismusgrave)
    echo "PR Created: ${PULL_REQUEST_URL}"
    o ${PULL_REQUEST_URL}    

    PR_TITLE=$3
    prCreatedAlert "${PULL_REQUEST_URL}" "${PR_TITLE}"
}

function jsonLint()
{
   echo "$1" | jq '.'
}

function brokerLogs(){
	tail -f /var/hosting/tomcatlogs/justride_broker.log
}

function man-preview() {
  man -t "$@" | open -f -a Preview
}

function push()
{
  git push -u origin `br`
}
