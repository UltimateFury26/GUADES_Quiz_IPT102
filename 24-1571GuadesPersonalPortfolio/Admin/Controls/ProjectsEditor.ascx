<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ProjectsEditor.ascx.cs" Inherits="_24_1571GuadesPersonalPortfolio.ProjectsEditor" %>

<div class="editor-head">
    <div>
        <h2 class="editor-title">Recent Projects</h2>
        <p class="editor-intro">The pins shown on the Recent Projects board of Home. Empty optional fields are hidden there.</p>
    </div>
    <asp:Button ID="btnAdd" runat="server" Text="Add project" CssClass="pill-btn pill-btn-primary"
        CausesValidation="false" OnClick="btnAdd_Click" />
</div>

<asp:Panel ID="pnlMessage" runat="server" Visible="false" role="alert">
    <asp:Literal ID="litMessage" runat="server" Mode="Encode" />
</asp:Panel>

<!-- ADD / EDIT FORM (hidden until Add or Edit is clicked) -->
<asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="editor-card editor-form" DefaultButton="btnSave">
    <h2><asp:Literal ID="litFormTitle" runat="server" Mode="Encode" /></h2>
    <asp:HiddenField ID="hfProjectId" runat="server" Value="0" />

    <div class="form-field">
        <asp:Label runat="server" AssociatedControlID="txtTitle" CssClass="form-label" Text="Project title" />
        <asp:TextBox ID="txtTitle" runat="server" CssClass="form-input" MaxLength="150" />
        <asp:RequiredFieldValidator ID="rfvTitle" runat="server" ControlToValidate="txtTitle"
            Display="Dynamic" CssClass="form-error" ErrorMessage="Enter the project title." ValidationGroup="Projects" />
    </div>

    <div class="form-row">
        <div class="form-field">
            <asp:Label runat="server" AssociatedControlID="txtTechStack" CssClass="form-label" Text="Tech stack (optional)" />
            <asp:TextBox ID="txtTechStack" runat="server" CssClass="form-input" MaxLength="250" placeholder="ASP.NET Web Forms, C#, SQL Server" />
        </div>

        <div class="form-field">
            <asp:Label runat="server" AssociatedControlID="txtRole" CssClass="form-label" Text="My role (optional)" />
            <asp:TextBox ID="txtRole" runat="server" CssClass="form-input" MaxLength="100" />
        </div>
    </div>

    <div class="form-field">
        <asp:Label runat="server" AssociatedControlID="txtDetails" CssClass="form-label" Text="Details (optional)" />
        <asp:TextBox ID="txtDetails" runat="server" CssClass="form-input form-textarea" TextMode="MultiLine" Rows="5" MaxLength="2000" />
        <p class="form-hint">What the project is and what you built, up to 2000 characters.</p>
    </div>

    <div class="form-field">
        <asp:Label runat="server" AssociatedControlID="txtRepoUrl" CssClass="form-label" Text="Repository link (optional)" />
        <asp:TextBox ID="txtRepoUrl" runat="server" CssClass="form-input" MaxLength="250" TextMode="Url" placeholder="https://github.com/username/project" />
        <asp:RegularExpressionValidator ID="revRepoUrl" runat="server" ControlToValidate="txtRepoUrl"
            Display="Dynamic" CssClass="form-error" ValidationExpression="^https?://\S+$"
            ErrorMessage="Start the link with http:// or https://" ValidationGroup="Projects" />
        <p class="form-hint">Leave empty if there is no public repository; the &ldquo;View Repo&rdquo; link is then hidden on Home.</p>
    </div>

    <div class="form-field form-field-narrow">
        <asp:Label runat="server" AssociatedControlID="txtSortOrder" CssClass="form-label" Text="Display order (optional)" />
        <asp:TextBox ID="txtSortOrder" runat="server" CssClass="form-input" MaxLength="4" inputmode="numeric" />
        <asp:RangeValidator ID="rvSortOrder" runat="server" ControlToValidate="txtSortOrder" Type="Integer"
            MinimumValue="0" MaximumValue="9999" Display="Dynamic" CssClass="form-error"
            ErrorMessage="Enter a whole number from 0 to 9999." ValidationGroup="Projects" />
        <p class="form-hint">Lower numbers come first. Empty puts a new project last, or keeps the current position when editing.</p>
    </div>

    <div class="editor-actions">
        <asp:Button ID="btnSave" runat="server" Text="Save project" CssClass="pill-btn pill-btn-primary"
            ValidationGroup="Projects" OnClick="btnSave_Click" />
        <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="pill-btn pill-btn-secondary"
            CausesValidation="false" OnClick="btnCancel_Click" />
    </div>
</asp:Panel>

<!-- LIST -->
<asp:Panel ID="pnlList" runat="server" CssClass="table-scroll">
    <asp:Repeater ID="rptProjects" runat="server" OnItemDataBound="rptProjects_ItemDataBound" OnItemCommand="rptProjects_ItemCommand">
        <HeaderTemplate>
            <table class="data-table">
                <thead>
                    <tr>
                        <th scope="col">Project</th>
                        <th scope="col">Tech stack</th>
                        <th scope="col">Role</th>
                        <th scope="col">Repo</th>
                        <th scope="col">Order</th>
                        <th scope="col">Actions</th>
                    </tr>
                </thead>
                <tbody>
        </HeaderTemplate>
        <ItemTemplate>
                    <tr>
                        <td class="cell-strong cell-wrap"><%#: Eval("Title") %></td>
                        <td class="cell-wrap"><%#: OrDash(Eval("TechStack")) %></td>
                        <td class="cell-wrap"><%#: OrDash(Eval("Role")) %></td>
                        <td><%# RepoHtml(Eval("RepoUrl")) %></td>
                        <td><%# Eval("SortOrder") %></td>
                        <td class="cell-actions">
                            <asp:Button ID="btnEdit" runat="server" Text="Edit" CssClass="row-btn" CausesValidation="false" />
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

<asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="empty-state">
    <p class="empty-title">No projects yet</p>
    <p class="empty-text">Click &ldquo;Add project&rdquo; to create the first one. Until you do, the Recent Projects board is hidden on Home.</p>
</asp:Panel>
