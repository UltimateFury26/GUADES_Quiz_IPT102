<%@ Page Title="Manage Users" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ManageUsers.aspx.cs" Inherits="_24_1571GuadesPersonalPortfolio.ManageUsersPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <div class="admin-head">
        <div>
            <h1 class="admin-title">Manage Users</h1>
            <p class="admin-sub">Registered accounts only. The website's own content is managed under Content.</p>
        </div>
        <span class="admin-count"><asp:Literal ID="litCount" runat="server" ClientIDMode="Static" Mode="Encode" /></span>
    </div>

    <asp:Panel ID="pnlMessage" runat="server" Visible="false" role="alert">
        <asp:Literal ID="litMessage" runat="server" Mode="Encode" />
    </asp:Panel>

    <!-- SEARCH AND FILTER: filters the table below as you type, with no page reload -->
    <div class="filter-bar">
        <input type="text" id="userSearchInput" class="form-input filter-input" maxlength="100"
            placeholder="Search username, email or phone" aria-label="Search users"
            autocomplete="off" spellcheck="false" />
        <select id="userStatusFilter" class="form-input filter-select" aria-label="Filter by status">
            <option value="">All statuses</option>
            <option value="Active">Active</option>
            <option value="Inactive">Inactive</option>
        </select>
    </div>

    <!-- USERS TABLE -->
    <asp:Panel ID="pnlResults" runat="server" ClientIDMode="Static" CssClass="table-scroll">
        <asp:Repeater ID="rptUsers" runat="server" OnItemDataBound="rptUsers_ItemDataBound" OnItemCommand="rptUsers_ItemCommand">
            <HeaderTemplate>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th scope="col"><asp:LinkButton runat="server" CommandName="Sort" CommandArgument="UserId" CssClass='<%# SortHeaderClass("UserId") %>' Text='<%# SortHeaderText("ID", "UserId") %>' CausesValidation="false" /></th>
                            <th scope="col"><asp:LinkButton runat="server" CommandName="Sort" CommandArgument="Username" CssClass='<%# SortHeaderClass("Username") %>' Text='<%# SortHeaderText("Username", "Username") %>' CausesValidation="false" /></th>
                            <th scope="col"><asp:LinkButton runat="server" CommandName="Sort" CommandArgument="Email" CssClass='<%# SortHeaderClass("Email") %>' Text='<%# SortHeaderText("Email", "Email") %>' CausesValidation="false" /></th>
                            <th scope="col"><asp:LinkButton runat="server" CommandName="Sort" CommandArgument="Phone" CssClass='<%# SortHeaderClass("Phone") %>' Text='<%# SortHeaderText("Phone", "Phone") %>' CausesValidation="false" /></th>
                            <th scope="col"><asp:LinkButton runat="server" CommandName="Sort" CommandArgument="Role" CssClass='<%# SortHeaderClass("Role") %>' Text='<%# SortHeaderText("Role", "Role") %>' CausesValidation="false" /></th>
                            <th scope="col"><asp:LinkButton runat="server" CommandName="Sort" CommandArgument="Status" CssClass='<%# SortHeaderClass("Status") %>' Text='<%# SortHeaderText("Status", "Status") %>' CausesValidation="false" /></th>
                            <th scope="col"><asp:LinkButton runat="server" CommandName="Sort" CommandArgument="CreatedAt" CssClass='<%# SortHeaderClass("CreatedAt") %>' Text='<%# SortHeaderText("Joined", "CreatedAt") %>' CausesValidation="false" /></th>
                            <th scope="col"><asp:LinkButton runat="server" CommandName="Sort" CommandArgument="LastLoginAt" CssClass='<%# SortHeaderClass("LastLoginAt") %>' Text='<%# SortHeaderText("Last login", "LastLoginAt") %>' CausesValidation="false" /></th>
                            <th scope="col">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
            </HeaderTemplate>
            <ItemTemplate>
                        <tr data-username="<%#: Eval("Username") %>" data-email="<%#: Eval("Email") %>"
                            data-phone="<%#: Eval("Phone") %>" data-status="<%#: Eval("Status") %>">
                            <td><%# Eval("UserId") %></td>
                            <td class="cell-strong"><%#: Eval("Username") %><%# YouTag(Eval("UserId")) %></td>
                            <td class="cell-wrap"><%#: Eval("Email") %></td>
                            <td><%#: Eval("Phone") %></td>
                            <td><span class="<%# RoleBadgeClass(Eval("Role")) %>"><%#: Eval("Role") %></span></td>
                            <td><span class="<%# StatusBadgeClass(Eval("Status")) %>"><%#: Eval("Status") %></span></td>
                            <td><%# FormatDate(Eval("CreatedAt")) %></td>
                            <td><%# FormatLastLogin(Eval("LastLoginAt")) %></td>
                            <td class="cell-actions">
                                <asp:Button ID="btnToggle" runat="server" CssClass="row-btn" CausesValidation="false" />
                                <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="row-btn row-btn-danger" CausesValidation="false" />
                            </td>
                        </tr>
            </ItemTemplate>
            <FooterTemplate>
                    </tbody>
                </table>
            </FooterTemplate>
        </asp:Repeater>
    </asp:Panel>

    <!-- EMPTY STATE: no users in the database at all -->
    <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="empty-state">
        <p class="empty-title">No users found</p>
        <p class="empty-text">Once someone signs up, they will appear here.</p>
    </asp:Panel>

    <!-- NO MATCHES: there are users, but none match the current search/filter (client-side only) -->
    <p id="userNoMatches" class="empty-text" style="display:none">
        No users match your search. Try a different search, or choose &ldquo;All statuses&rdquo;.
    </p>

</asp:Content>
