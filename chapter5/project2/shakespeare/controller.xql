xquery version "3.0";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

if ($exist:path eq "/") then
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="index.html"/>
    </dispatch>
else if (starts-with($exist:path, "/plays/")) then
    (: use extra router for the plays, so we do not have to hardcode every piece!, ID's should be the play's short title
     : assumption then of course is that those are unique
     : Idea taken from the original shakespeare demo :)
    let $id := replace($exist:resource,"^(.*)\.\w+$", "$1")
    let $fwd := if (ends-with($exist:resource, ".html")) then
                        "view-play.html"
                    else
                        "view-play-summary.html"
    return
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                
                    <forward url="{$exist:controller}/{$fwd}">
                </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                        <add-parameter name="id" value="{util:unescape-uri($id,'UTF-8')}"/>
                    </forward>
                </view>
                <error-handler>
                    <forward url="{$exist:controller}/error-page.html" method="get"/>
                    <forward url="{$exist:controller}/modules/view.xql"/>
                </error-handler>
            </dispatch>
else if (starts-with($exist:path, "/parts/")) then
    (: use extra router for the plays, so we do not have to hardcode every piece!, ID's should be the play's short title
     : assumption then of course is that those are unique
     : Idea taken from the original shakespeare demo :)
     let $regex := "^/parts/(.*)/(.*)/(.*)/(.*)"
    let $id := replace($exist:path,$regex, "$1")
    let $char := replace($exist:path,$regex ,"$2")
    let $act := replace($exist:path,$regex, "$3")
    let $scene := replace($exist:path,$regex, "$4")
    return
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">        
                <forward url="{$exist:controller}/parts.html">
                </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                        <add-parameter name="id" value="{util:unescape-uri($id,'UTF-8')}"/>
                        <add-parameter name="char" value="{util:unescape-uri($char,'UTF-8')}"/>
                        <add-parameter name="act" value="{util:unescape-uri($act,'UTF-8')}"/>
                        <add-parameter name="scene" value="{util:unescape-uri($scene,'UTF-8')}"/>
                    </forward>
                </view>
                <error-handler>
                    <forward url="{$exist:controller}/error-page.html" method="get"/>
                    <forward url="{$exist:controller}/modules/view.xql"/>
                </error-handler>
            </dispatch>
else if (ends-with($exist:resource, ".html")) then
    (: the html page is run through view.xql to expand templates :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>
(: Resource paths starting with $shared are loaded from the shared-resources app :)
else if (contains($exist:path, "/$shared/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>
else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>
