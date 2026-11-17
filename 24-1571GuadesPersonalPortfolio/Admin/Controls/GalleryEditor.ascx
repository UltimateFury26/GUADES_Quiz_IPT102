<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="GalleryEditor.ascx.cs" Inherits="_24_1571GuadesPersonalPortfolio.GalleryEditor" %>

<div class="editor-head">
    <div>
        <h2 class="editor-title">Gallery</h2>
        <p class="editor-intro">The photos shown on the Gallery board of Home. Each one needs a photo; the caption is optional.</p>
    </div>
    <asp:Button ID="btnAdd" runat="server" Text="Add photo" CssClass="pill-btn pill-btn-primary"
        CausesValidation="false" OnClick="btnAdd_Click" />
</div>

<asp:Panel ID="pnlMessage" runat="server" Visible="false" role="alert">
    <asp:Literal ID="litMessage" runat="server" Mode="Encode" />
</asp:Panel>

<!-- ADD / EDIT FORM (hidden until Add or Edit is clicked) -->
<asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="editor-card editor-form" DefaultButton="btnSave">
    <h2><asp:Literal ID="litFormTitle" runat="server" Mode="Encode" /></h2>
    <asp:HiddenField ID="hfGalleryId" runat="server" Value="0" />

    <div class="form-field">
        <span class="form-label">Photo</span>
        <div class="avatar-edit">
            <asp:Panel ID="pnlCurrentPhoto" runat="server" Visible="false">
                <asp:Image ID="imgPhoto" runat="server" CssClass="photo-preview" AlternateText="Current photo" />
            </asp:Panel>
            <div class="avatar-controls">
                <asp:FileUpload ID="fuPhoto" runat="server" CssClass="form-file" accept=".jpg,.jpeg,.png,.gif" />
                <p class="form-hint">
                    <asp:Literal ID="litPhotoHint" runat="server" Mode="Encode" />
                </p>
            </div>
        </div>
    </div>

    <div class="form-field">
        <asp:Label runat="server" AssociatedControlID="txtCaption" CssClass="form-label" Text="Caption (optional)" />
        <asp:TextBox ID="txtCaption" runat="server" CssClass="form-input" MaxLength="200" />
        <p class="form-hint">A short line, up to 200 characters. It is used as the photo's description for screen readers.</p>
    </div>

    <div class="form-field form-field-narrow">
        <asp:Label runat="server" AssociatedControlID="txtSortOrder" CssClass="form-label" Text="Display order (optional)" />
        <asp:TextBox ID="txtSortOrder" runat="server" CssClass="form-input" MaxLength="4" inputmode="numeric" />
        <asp:RangeValidator ID="rvSortOrder" runat="server" ControlToValidate="txtSortOrder" Type="Integer"
            MinimumValue="0" MaximumValue="9999" Display="Dynamic" CssClass="form-error"
            ErrorMessage="Enter a whole number from 0 to 9999." ValidationGroup="Gallery" />
        <p class="form-hint">Lower numbers come first. Empty puts a new photo last, or keeps the current position when editing. The first three photos also appear on the Gallery tile.</p>
    </div>

    <div class="editor-actions">
        <asp:Button ID="btnSave" runat="server" Text="Save photo" CssClass="pill-btn pill-btn-primary"
            ValidationGroup="Gallery" OnClick="btnSave_Click" />
        <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="pill-btn pill-btn-secondary"
            CausesValidation="false" OnClick="btnCancel_Click" />
    </div>
</asp:Panel>

<!-- LIST -->
<asp:Panel ID="pnlList" runat="server" CssClass="table-scroll">
    <asp:Repeater ID="rptGallery" runat="server" OnItemDataBound="rptGallery_ItemDataBound" OnItemCommand="rptGallery_ItemCommand">
        <HeaderTemplate>
            <table class="data-table">
                <thead>
                    <tr>
                        <th scope="col">Photo</th>
                        <th scope="col">Caption</th>
                        <th scope="col">Order</th>
                        <th scope="col">Actions</th>
                    </tr>
                </thead>
                <tbody>
        </HeaderTemplate>
        <ItemTemplate>
                    <tr>
                        <td><%# ThumbHtml(Eval("ImagePath")) %></td>
                        <td class="cell-wrap"><%#: OrDash(Eval("Caption")) %></td>
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
    <p class="empty-title">No photos yet</p>
    <p class="empty-text">Click &ldquo;Add photo&rdquo; to upload the first one. Until you do, the Gallery board is hidden on Home.</p>
</asp:Panel>
