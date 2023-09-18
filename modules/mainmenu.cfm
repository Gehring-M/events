<!--- CSS menü --->
<cfset qItems = getMenuItems(0)>
<cfif qItems.recordcount>
<cfoutput>
<div class="mainNav">
	<ul>
	<cfloop query="qItems">
		<cfset qSubItems = getMenuItems(qItems.node_fk)>
		<li><a href="#getPageUrl(qItems.id)#">#getPageTitle(qItems.id)#
		<cfif qSubItems.recordcount>
			<!--[if IE 7]><!--></a><!--<![endif]-->
			<!--[if lte IE 6]><table cellpadding="0" cellspacing="0"><tr><td><![endif]-->
			<ul>
			<cfloop query="qSubItems">
				<cfset qSubsubItems = getMenuItems(qSubItems.node_fk)>
				<li><a<cfif qSubsubItems.recordcount> class="drop"</cfif> href="#getPageUrl(qSubItems.id)#">#getPageTitle(qSubItems.id)#
				<cfif qSubsubItems.recordcount>
					<!--[if IE 7]><!--></a><!--<![endif]-->
					<!--[if lte IE 6]><table><tr><td><![endif]-->
					<ul>
						<cfloop query="qSubsubItems">
							<li><a href="#getPageUrl(qSubsubItems.id)#">#getPageTitle(qSubsubItems.id)#</a></li>
						</cfloop>
					</ul>
					<!--[if lte IE 6]></td></tr></table></a><![endif]-->
					<cfelse>
					</a>
				</cfif>
				</li>
			</cfloop>
			</ul>
			<!--[if lte IE 6]></td></tr></table></a><![endif]-->
			<cfelse>
			</a>
		</cfif>
		</li>
	</cfloop>
	</ul>
</div>
</cfoutput>
</cfif>
<!--- Ende CSS menü --->