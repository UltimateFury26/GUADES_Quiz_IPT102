<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="EducationEditor.ascx.cs" Inherits="_24_1571GuadesPersonalPortfolio.EducationEditor" %>

<div class="editor-head">
    <div>
        <h2 class="editor-title">Educational Attainment</h2>
        <p class="editor-intro">The schools shown on the Education board of Home.</p>
    </div>
    <asp:Button ID="btnAdd" runat="server" Text="Add school" CssClass="pill-btn pill-btn-primary"
        CausesValidation="false" OnClick="btnAdd_Click" />
</div>

<asp:Panel ID="pnlMessage" runat="server" Visible="false" role="alert">
    <asp:Literal ID="litMessage" runat="server" Mode="Encode" />
</asp:Panel>

<!-- ADD / EDIT FORM (hidden until Add or Edit is clicked) -->
<asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="editor-card editor-form" DefaultButton="btnSave">
    <h2><asp:Literal ID="litFormTitle" runat="server" Mode="Encode" /></h2>
    <asp:HiddenField ID="hfEducationId" runat="server" Value="0" />

    <div class="form-field">
        <asp:Label runat="server" AssociatedControlID="txtSchool" CssClass="form-label" Text="School name" />
        <asp:TextBox ID="txtSchool" runat="server" CssClass="form-input" MaxLength="150" />
        <asp:RequiredFieldValidator ID="rfvSchool" runat="server" ControlToValidate="txtSchool"
            Display="Dynamic" CssClass="form-error" ErrorMessage="Enter the school name." ValidationGroup="Education" />
    </div>

    <div class="form-row">
        <div class="form-field">
            <asp:Label runat="server" AssociatedControlID="txtLevel" CssClass="form-label" Text="Level" />
            <asp:TextBox ID="txtLevel" runat="server" CssClass="form-input" MaxLength="50" list="educationLevels" autocomplete="off" />
            <datalist id="educationLevels">
                <option value="Elementary" />
                <option value="Junior High School" />
                <option value="Senior High School" />
                <option value="College" />
                <option value="Graduate School" />
            </datalist>
            <asp:RequiredFieldValidator ID="rfvLevel" runat="server" ControlToValidate="txtLevel"
                Display="Dynamic" CssClass="form-error" ErrorMessage="Enter the level." ValidationGroup="Education" />
        </div>

        <div class="form-field">
            <asp:Label runat="server" AssociatedControlID="txtProgram" CssClass="form-label" Text="Program (optional)" />
            <asp:TextBox ID="txtProgram" runat="server" CssClass="form-input" MaxLength="150" />
        </div>
    </div>

    <div class="form-row">
        <div class="form-field">
            <asp:Label runat="server" AssociatedControlID="txtStartYear" CssClass="form-label" Text="Start year (optional)" />
            <asp:TextBox ID="txtStartYear" runat="server" CssClass="form-input" MaxLength="4" inputmode="numeric" />
            <asp:RangeValidator ID="rvStartYear" runat="server" ControlToValidate="txtStartYear" Type="Integer"
                MinimumValue="1950" MaximumValue="2100" Display="Dynamic" CssClass="form-error"
                ErrorMessage="Enter a year between 1950 and 2100." ValidationGroup="Education" />
        </div>

        <div class="form-field">
            <asp:Label runat="server" AssociatedControlID="txtEndYear" CssClass="form-label" Text="End year (optional)" />
            <asp:TextBox ID="txtEndYear" runat="server" CssClass="form-input" MaxLength="4" inputmode="numeric" />
            <asp:RangeValidator ID="rvEndYear" runat="server" ControlToValidate="txtEndYear" Type="Integer"
                MinimumValue="1950" MaximumValue="2100" Display="Dynamic" CssClass="form-error"
                ErrorMessage="Enter a year between 1950 and 2100." ValidationGroup="Education" />
        </div>
    </div>
    <asp:CustomValidator ID="cvYears" runat="server" Display="Dynamic" CssClass="form-error"
        ErrorMessage="Check the years." ValidationGroup="Education" OnServerValidate="cvYears_ServerValidate" />
    <p class="form-hint">Leave the end year empty if you are still studying there. Leave both empty if the years are unknown; they are then hidden.</p>

    <div class="form-field">
        <asp:Label runat="server" AssociatedControlID="txtDescription" CssClass="form-label" Text="Description (optional)" />
        <asp:TextBox ID="txtDescription" runat="server" CssClass="form-input form-textarea" TextMode="MultiLine" Rows="4" MaxLength="1000" />
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
            ErrorMessage="Enter a whole number from 0 to 9999." ValidationGroup="Education" />
        <p class="form-hint">Lower numbers come first. Empty puts a new school last, or keeps the current position when editing.</p>
    </div>

    <div class="editor-actions">
        <asp:Button ID="btnSave" runat="server" Text="Save school" CssClass="pill-btn pill-btn-primary"
            ValidationGroup="Education" OnClick="btnSave_Click" />
        <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="pill-btn pill-btn-secondary"
            CausesValidation="false" OnClick="btnCancel_Click" />
    </div>
</asp:Panel>

<!-- LIST -->
<asp:Panel ID="pnlList" runat="server" CssClass="table-scroll">
    <asp:Repeater ID="rptSchools" runat="server" OnItemDataBound="rptSchools_ItemDataBound" OnItemCommand="rptSchools_ItemCommand">
        <HeaderTemplate>
            <table class="data-table">
                <thead>
                    <tr>
                        <th scope="col">Photo</th>
                        <th scope="col">School</th>
                        <th scope="col">Level</th>
                        <th scope="col">Program</th>
                        <th scope="col">Years</th>
                        <th scope="col">Order</th>
                        <th scope="col">Actions</th>
                    </tr>
                </thead>
                <tbody>
        </HeaderTemplate>
        <ItemTemplate>
                    <tr>
                        <td><%# ThumbHtml(Eval("PhotoPath")) %></td>
                        <td class="cell-strong cell-wrap"><%#: Eval("SchoolName") %></td>
                        <td><%#: Eval("Level") %></td>
                        <td class="cell-wrap"><%#: Eval("Program") %></td>
                        <td><%#: FormatYears(Eval("StartYear"), Eval("EndYear")) %></td>
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
    <p class="empty-title">No schools yet</p>
    <p class="empty-text">Click &ldquo;Add school&rdquo; to create the first one.</p>
</asp:Panel>
