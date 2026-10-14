import { LightningElement, api, wire, track } from 'lwc';
import getFilteredCampaigns from '@salesforce/apex/businessScenario.getFilteredCampaigns';
import getCampaignTypeOptions from '@salesforce/apex/businessScenario.getCampaignTypeOptions';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';

const COLUMNS = [
    { label: 'Campaign Name', fieldName: 'name', type: 'text' },
    { label: 'Campaign Type', fieldName: 'type', type: 'text' },
    { label: 'Campaign Status', fieldName: 'status', type: 'text' },
    { label: 'Start Date', fieldName: 'startDate', type: 'date' },
    { label: 'End Date', fieldName: 'endDate', type: 'date' },
    { 
        label: 'Enrollment Status', 
        fieldName: 'enrollmentStatus', 
        type: 'text',
        cellAttributes: {
            class: { fieldName: 'enrollmentBadgeClass' }
        }
    }
];

export default class BusinessScenario extends LightningElement {
    @api alreadyEnrolledIds = '';
    @api 
    get selectedCampaignIds() {
        return Array.from(this.selectedRowIds).join(',');
    }
    set selectedCampaignIds(val) {
        if (val) {
            val.split(',').forEach(id => this.selectedRowIds.add(id.trim()));
        }
    }

    @track searchName = '';
    @track selectedType = 'ALL';
    @track filterStartDate = null;
    @track filterEndDate = null;
    
    @track typeOptions = [];
    @track allCampaigns = [];
    @track selectedRowIds = new Set();
    @track errorMessage = '';

    columns = COLUMNS;

    connectedCallback() {
        this.loadTypeOptions();
    }

    loadTypeOptions() {
        getCampaignTypeOptions()
            .then(data => {
                this.typeOptions = data;
            })
            .catch(error => {
                console.error('Error fetching campaign types:', error);
            });
    }

    @wire(getFilteredCampaigns, {
        searchName: '$searchName',
        campaignType: '$selectedType',
        filterStartDate: '$filterStartDate',
        filterEndDate: '$filterEndDate',
        alreadyEnrolledIdsStr: '$alreadyEnrolledIds'
    })
    wiredCampaigns({ error, data }) {
        if (data) {
            this.allCampaigns = data.map(row => ({
                ...row,
                enrollmentBadgeClass: row.isAlreadyEnrolled ? 'slds-text-color_error slds-font-weight_bold' : 'slds-text-color_success'
            }));
            this.errorMessage = '';
        } else if (error) {
            console.error('Error loading campaigns:', error);
        }
    }

    get tableData() {
        return this.allCampaigns;
    }

    get selectedRowKeys() {
        return Array.from(this.selectedRowIds);
    }

    get selectedCount() {
        return this.selectedRowIds.size;
    }

    get isNextDisabled() {
        return this.selectedCount === 0;
    }

    handleNameChange(event) {
        this.searchName = event.target.value;
    }

    handleTypeChange(event) {
        this.selectedType = event.detail.value;
    }

    handleStartDateChange(event) {
        this.filterStartDate = event.target.value;
    }

    handleEndDateChange(event) {
        this.filterEndDate = event.target.value;
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        const currentDisplayedIds = new Set(this.allCampaigns.map(c => c.id));

        // Preserve selections from other filtered views while updating current view
        currentDisplayedIds.forEach(id => {
            this.selectedRowIds.delete(id);
        });

        selectedRows.forEach(row => {
            if (!row.isAlreadyEnrolled) {
                this.selectedRowIds.add(row.id);
            }
        });

        if (this.selectedCount > 0) {
            this.errorMessage = '';
        }
    }

    // Optional handler if embedded in a Flow footer or custom action
    @api
    validate() {
        if (this.selectedCount === 0) {
            return {
                isValid: false,
                errorMessage: 'Please select at least one new campaign before proceeding.'
            };
        }
        return { isValid: true };
    }
}