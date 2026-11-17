<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="SkillsEditor.ascx.cs" Inherits="_24_1571GuadesPersonalPortfolio.SkillsEditor" %>

<div class="editor-head">
    <div>
        <h2 class="editor-title">Skills</h2>
        <p class="editor-intro">Each skill appears on the board for its category: Frontend, Backend, or Tools &amp; Platforms.</p>
    </div>
    <asp:Button ID="btnAdd" runat="server" Text="Add skill" CssClass="pill-btn pill-btn-primary"
        CausesValidation="false" OnClick="btnAdd_Click" />
</div>

<asp:Panel ID="pnlMessage" runat="server" Visible="false" role="alert">
    <asp:Literal ID="litMessage" runat="server" Mode="Encode" />
</asp:Panel>

<!-- ADD / EDIT FORM (hidden until Add or Edit is clicked) -->
<asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="editor-card editor-form" DefaultButton="btnSave">
    <h2><asp:Literal ID="litFormTitle" runat="server" Mode="Encode" /></h2>
    <asp:HiddenField ID="hfSkillId" runat="server" Value="0" />

    <div class="form-row">
        <div class="form-field">
            <asp:Label runat="server" AssociatedControlID="txtName" CssClass="form-label" Text="Skill name" />
            <asp:TextBox ID="txtName" runat="server" CssClass="form-input" MaxLength="100" />
            <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtName"
                Display="Dynamic" CssClass="form-error" ErrorMessage="Enter the skill name." ValidationGroup="Skill" />
        </div>

        <div class="form-field">
            <asp:Label runat="server" AssociatedControlID="ddlCategory" CssClass="form-label" Text="Category" />
            <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-input" />
        </div>
    </div>

    <div class="form-field">
        <asp:Label runat="server" AssociatedControlID="txtDescription" CssClass="form-label" Text="Description (optional)" />
        <asp:TextBox ID="txtDescription" runat="server" CssClass="form-input form-textarea" TextMode="MultiLine" Rows="5" MaxLength="1500" />
        <p class="form-hint">Shown when a visitor opens the skill. Up to 1500 characters.</p>
    </div>

    <div class="form-field form-field-narrow">
        <asp:Label runat="server" AssociatedControlID="txtSortOrder" CssClass="form-label" Text="Display order (optional)" />
        <asp:TextBox ID="txtSortOrder" runat="server" CssClass="form-input" MaxLength="4" inputmode="numeric" />
        <asp:RangeValidator ID="rvSortOrder" runat="server" ControlToValidate="txtSortOrder" Type="Integer"
            MinimumValue="0" MaximumValue="9999" Display="Dynamic" CssClass="form-error"
            ErrorMessage="Enter a whole number from 0 to 9999." ValidationGroup="Skill" />
        <p class="form-hint">Lower numbers come first. Empty puts a new skill last, or keeps the current position when editing.</p>
    </div>

    <div class="editor-actions">
        <asp:Button ID="btnSave" runat="server" Text="Save skill" CssClass="pill-btn pill-btn-primary"
            ValidationGroup="Skill" OnClick="btnSave_Click" />
        <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="pill-btn pill-btn-secondary"
            CausesValidation="false" OnClick="btnCancel_Click" />
    </div>
</asp:Panel>

<!-- LIST -->
<asp:Panel ID="pnlList" runat="server" CssClass="table-scroll">
    <asp:Repeater ID="rptSkills" runat="server" OnItemDataBound="rptSkills_ItemDataBound" OnItemCommand="rptSkills_ItemCommand">
        <HeaderTemplate>
            <table class="data-table">
                <thead>
                    <tr>
                        <th scope="col">Skill</th>
                        <th scope="col">Category</th>
                        <th scope="col">Description</th>
                        <th scope="col">Order</th>
                        <th scope="col">Actions</th>
                    </tr>
                </thead>
                <tbody>
        </HeaderTemplate>
        <ItemTemplate>
                    <tr>
                        <td class="cell-strong cell-wrap"><%#: Eval("Name") %></td>
                        <td><span class="badge badge-user"><%#: CategoryLabel(Eval("Category")) %></span></td>
                        <td class="cell-wrap cell-desc"><%#: Shorten(Eval("Description")) %></td>
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
    <p class="empty-title">No skills yet</p>
    <p class="empty-text">Click &ldquo;Add skill&rdquo; to create the first one.</p>
</asp:Panel>
