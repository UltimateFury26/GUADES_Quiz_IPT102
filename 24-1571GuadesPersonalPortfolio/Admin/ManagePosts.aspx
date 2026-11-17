<%@ Page Title="Manage Posts" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ManagePosts.aspx.cs" Inherits="_24_1571GuadesPersonalPortfolio.ManagePostsPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <div class="admin-head">
        <div>
            <h1 class="admin-title">Manage Posts</h1>
            <p class="admin-sub">Announcements for every logged-in user. Only published posts appear on Home; drafts stay hidden.</p>
        </div>
        <div class="admin-head-actions">
            <span class="admin-count"><asp:Literal ID="litCount" runat="server" Mode="Encode" /></span>
            <asp:Button ID="btnAdd" runat="server" Text="New announcement" CssClass="pill-btn pill-btn-primary"
                CausesValidation="false" OnClick="btnAdd_Click" />
        </div>
    </div>

    <asp:Panel ID="pnlMessage" runat="server" Visible="false" role="alert">
        <asp:Literal ID="litMessage" runat="server" Mode="Encode" />
    </asp:Panel>

    <!-- ADD / EDIT FORM (hidden until New announcement or Edit is clicked) -->
    <asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="editor-card editor-form">
        <h2><asp:Literal ID="litFormTitle" runat="server" Mode="Encode" /></h2>
        <asp:HiddenField ID="hfPostId" runat="server" Value="0" />

        <div class="form-field">
            <asp:Label runat="server" AssociatedControlID="txtTitle" CssClass="form-label" Text="Title" />
            <asp:TextBox ID="txtTitle" runat="server" CssClass="form-input" MaxLength="150" />
            <asp:RequiredFieldValidator ID="rfvTitle" runat="server" ControlToValidate="txtTitle"
                Display="Dynamic" CssClass="form-error" ErrorMessage="Enter a title for the announcement." ValidationGroup="Posts" />
        </div>

        <div class="form-field">
            <asp:Label runat="server" AssociatedControlID="txtBody" CssClass="form-label" Text="Message" />
            <asp:TextBox ID="txtBody" runat="server" CssClass="form-input form-textarea" TextMode="MultiLine" Rows="6" />
            <asp:RequiredFieldValidator ID="rfvBody" runat="server" ControlToValidate="txtBody"
                Display="Dynamic" CssClass="form-error" ErrorMessage="Enter the announcement message." ValidationGroup="Posts" />
            <p class="form-hint">Up to 4,000 characters. Line breaks are kept when the post is shown.</p>
        </div>

        <div class="form-field">
            <asp:CheckBox ID="chkPublish" runat="server" CssClass="form-check" Text="Publish (visible to users on Home)" />
            <p class="form-hint">Leave unchecked to save as a draft. You can publish it later from the list.</p>
        </div>

        <div class="editor-actions">
            <asp:Button ID="btnSave" runat="server" Text="Save announcement" CssClass="pill-btn pill-btn-primary"
                ValidationGroup="Posts" OnClick="btnSave_Click" />
            <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="pill-btn pill-btn-secondary"
                CausesValidation="false" OnClick="btnCancel_Click" />
        </div>
    </asp:Panel>

    <!-- LIST -->
    <asp:Panel ID="pnlList" runat="server" CssClass="table-scroll">
        <asp:Repeater ID="rptPosts" runat="server" OnItemDataBound="rptPosts_ItemDataBound" OnItemCommand="rptPosts_ItemCommand">
            <HeaderTemplate>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th scope="col"><asp:LinkButton runat="server" CommandName="Sort" CommandArgument="Title" CssClass='<%# SortHeaderClass("Title") %>' Text='<%# SortHeaderText("Announcement", "Title") %>' CausesValidation="false" /></th>
                            <th scope="col"><asp:LinkButton runat="server" CommandName="Sort" CommandArgument="IsPublished" CssClass='<%# SortHeaderClass("IsPublished") %>' Text='<%# SortHeaderText("Status", "IsPublished") %>' CausesValidation="false" /></th>
                            <th scope="col"><asp:LinkButton runat="server" CommandName="Sort" CommandArgument="CreatedAt" CssClass='<%# SortHeaderClass("CreatedAt") %>' Text='<%# SortHeaderText("Posted", "CreatedAt") %>' CausesValidation="false" /></th>
                            <th scope="col"><asp:LinkButton runat="server" CommandName="Sort" CommandArgument="AuthorName" CssClass='<%# SortHeaderClass("AuthorName") %>' Text='<%# SortHeaderText("Author", "AuthorName") %>' CausesValidation="false" /></th>
                            <th scope="col">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
            </HeaderTemplate>
            <ItemTemplate>
                        <tr>
                            <td class="cell-wrap">
                                <p class="post-title"><%#: Eval("Title") %></p>
                                <p class="post-preview"><%#: Preview(Eval("Body")) %></p>
                            </td>
                            <td><%# StatusHtml(Eval("IsPublished")) %></td>
                            <td><%# PostedHtml(Container.DataItem) %></td>
                            <td><%#: Eval("AuthorName") %></td>
                            <td class="cell-actions">
                                <asp:Button ID="btnEdit" runat="server" Text="Edit" CssClass="row-btn" CausesValidation="false" />
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

    <!-- EMPTY STATE -->
    <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="empty-state">
        <p class="empty-title">No announcements yet</p>
        <p class="empty-text">Click &ldquo;New announcement&rdquo; to write the first one. Until one is published, the announcement card and board are hidden on Home.</p>
    </asp:Panel>

</asp:Content>
