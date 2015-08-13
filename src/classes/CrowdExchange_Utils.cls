public with sharing class CrowdExchange_Utils {
	public CrowdExchange_Utils() {
		
	}
	public static final String SITE_PREFIX = Site.getPathPrefix();
    /**
     * Gets communities avaliable for current user
     * @return ConnectApi.CommunityPage
     */
    public static ConnectApi.CommunityPage getCommunities() {
        return ConnectApi.Communities.getCommunities();
    }
    /**
     * Gets current community Id
     * @return Community Id ot null for internal
     */
    public static String getCurrentCommunityId() {
        ConnectApi.CommunityPage cp = null;
        if (!Test.isRunningTest())
            cp = getCommunities();
        else {
            //Test hack
            cp = new ConnectApi.CommunityPage();
            ConnectApi.Community com = new ConnectApi.Community();
            com.urlPathPrefix = '/';
            cp.communities = new List<ConnectApi.Community> {
                com
            };
        }
        String sitePath = SITE_PREFIX;

        if (!cp.communities.isEmpty()) {
            for (ConnectApi.Community community : cp.communities) {
                if (sitePath.contains(community.urlPathPrefix))
                    return community.id;
            }
        }
        return null;
    }
}