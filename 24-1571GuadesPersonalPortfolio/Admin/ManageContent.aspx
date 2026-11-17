<%@ Page Title="Manage Content" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ManageContent.aspx.cs" Inherits="_24_1571GuadesPersonalPortfolio.ManageContentPage" %>
<%@ Import Namespace="_24_1571GuadesPersonalPortfolio" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <div class="admin-head">
        <div>
            <h1 class="admin-title">Manage Content</h1>
            <p class="admin-sub">The website's own content. Signed-in users see exactly what you save here.</p>
        </div>
    </div>

    <nav class="tab-bar" aria-label="Content sections">
        <% foreach (ContentTab tab in AllTabs) { %>
        <a class="tab-link<%= TabActiveClass(tab) %>" href="<%: TabUrl(tab) %>"><%: tab.Title %></a>
        <% } %>
    </nav>

    <asp:PlaceHolder ID="phEditor" runat="server" />

</asp:Content>
