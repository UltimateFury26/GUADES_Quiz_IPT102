<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="HobbiesEditor.ascx.cs" Inherits="_24_1571GuadesPersonalPortfolio.HobbiesEditor" %>

<div class="editor-head">
    <div>
        <h2 class="editor-title">Hobbies &amp; Interest</h2>
        <p class="editor-intro">The pins shown on the Interests board of Home. A hobby without a photo appears as a text card.</p>
    </div>
    <asp:Button ID="btnAdd" runat="server" Text="Add hobby" CssClass="pill-btn pill-btn-primary"
        CausesValidation="false" OnClick="btnAdd_Click" />
</div>

<asp:Panel ID="pnlMessage" runat="server" Visible="false" role="alert">
    <asp:Literal ID="litMessage" runat="server" Mode="Encode" />
</asp:Panel>

<!-- ADD / EDIT FORM (hidden until Add or Edit is clicked) -->
<asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="editor-card editor-form" DefaultButton="btnSave">
    <h2><asp:Literal ID="litFormTitle" runat="server" Mode="Encode" /></h2>
    <asp:HiddenField ID="hfHobbyId" runat="server" Value="0" />

    <div class="form-field">
        <asp:Label runat="server" AssociatedControlID="txtTitle" CssClass="form-label" Text="Title" />
        <asp:TextBox ID="txtTitle" runat="server" CssClass="form-input" MaxLength="100" />
        <asp:RequiredFieldValidator ID="rfvTitle" runat="server" ControlToValidate="txtTitle"
            Display="Dynamic" CssClass="form-error" ErrorMessage="Enter a title for this hobby." ValidationGroup="Hobbies" />
    </div>

    <div class="form-field">
        <asp:Label runat="server" AssociatedControlID="txtDescription" CssClass="form-label" Text="Description (optional)" />
        <asp:TextBox ID="txtDescription" runat="server" CssClass="form-input form-textarea" TextMode="MultiLine" Rows="3" MaxLength="500" />
        <p class="form-hint">One or two sentences, up to 500 characters.</p>
    </div>

    <div class="form-field">
        <span class="form-label">Photo (optional)</span>
        <div class="avatar-edit">
            <asp:Panel ID="pnlCurrentPhoto" runat="server" Visible="false">
                <asp:Image ID="imgPhoto" runat="server" CssClass="photo-preview" AlternateText="Current photo" />
            </asp:Panel>
            <div class="avatar-controls">
                <asp:FileUpload ID="fuPhoto" runat="server" CssClass="form-file" accept=".jpg,.jpeg,.png,.gif" />
                <p class="form-hint">JPG, PNG or GIF, up to 5 MB. When editing, leave empty to keep the current photo.</p>
            </div>
        </div>
    </div>

    <div class="form-field form-field-narrow">
        <asp:Label runat="server" AssociatedControlID="txtSortOrder" CssClass="form-label" Text="Display order (optional)" />
        <asp:TextBox ID="txtSortOrder" runat="server" CssClass="form-input" MaxLength="4" inputmode="numeric" />
        <asp:RangeValidator ID="rvSortOrder" runat="server" ControlToValidate="txtSortOrder" Type="Integer"
            MinimumValue="0" MaximumValue="9999" Display="Dynamic" CssClass="form-error"
            ErrorMessage="Enter a whole number from 0 to 9999." ValidationGroup="Hobbies" />
        <p class="form-hint">Lower numbers come first. Empty puts a new hobby last, or keeps the current position when editing.</p>
    </div>

    <div class="editor-actions">
        <asp:Button ID="btnSave" runat="server" Text="Save hobby" CssClass="pill-btn pill-btn-primary"
            ValidationGroup="Hobbies" OnClick="btnSave_Click" />
        <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="pill-btn pill-btn-secondary"
            CausesValidation="false" OnClick="btnCancel_Click" />
    </div>
</asp:Panel>

<!-- LIST -->
<asp:Panel ID="pnlList" runat="server" CssClass="table-scroll">
    <asp:Repeater ID="rptHobbies" runat="server" OnItemDataBound="rptHobbies_ItemDataBound" OnItemCommand="rptHobbies_ItemCommand">
        <HeaderTemplate>
            <table class="data-table">
                <thead>
                    <tr>
                        <th scope="col">Photo</th>
                        <th scope="col">Title</th>
                        <th scope="col">Description</th>
                        <th scope="col">Order</th>
                        <th scope="col">Actions</th>
                    </tr>
                </thead>
                <tbody>
        </HeaderTemplate>
        <ItemTemplate>
                    <tr>
                        <td><%# ThumbHtml(Eval("ImagePath")) %></td>
                        <td class="cell-strong cell-wrap"><%#: Eval("Title") %></td>
                        <td class="cell-wrap"><%#: Preview(Eval("Description")) %></td>
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
    <p class="empty-title">No hobbies yet</p>
    <p class="empty-text">Click &ldquo;Add hobby&rdquo; to create the first one. Until you do, the Interests board is hidden on Home.</p>
</asp:Panel>
