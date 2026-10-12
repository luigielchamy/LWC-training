import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import LEASE_TYPE_FIELD from '@salesforce/schema/Opportunity.Lease_Type__c'; 

const FIELDS = [LEASE_TYPE_FIELD];

export default class QuoteAddition extends LightningElement {
    @api recordId;
    
    leaseType;
    
    landStartDate = '';
    landDuration = 0;
    @track calculatedEndDate = '';

    @wire(getRecord, { recordId: '\$recordId', fields: FIELDS })
    wiredOpportunity({ error, data }) {
        if (data) {
            this.leaseType = getFieldValue(data, LEASE_TYPE_FIELD);
        } else if (error) {
            this.showToast('Error', 'Failed to load Opportunity details.', 'error');
        }
    }

    get isOfficeOrRetail() {
        return this.leaseType === 'Office' || this.leaseType === 'Retail';
    }

    get isRetail() {
        return this.leaseType === 'Retail';
    }

    get isLand() {
        return this.leaseType === 'Land';
    }

    handleLandDateOrDurationChange(event) {
        const fieldLabel = event.target.label;
        
        if (event.target.fieldName === 'Proposed_Start_Date__c') {
            this.landStartDate = event.target.value;
        } else if (fieldLabel === 'Proposed Duration (Years)') {
            this.landDuration = parseInt(event.target.value, 10);
        }

        if (this.landStartDate && this.landDuration >= 30) {
            let startDate = new Date(this.landStartDate);

            startDate.setFullYear(startDate.getFullYear() + this.landDuration);
            this.calculatedEndDate = startDate.toISOString().split('T')[0];
        } else {
            this.calculatedEndDate = '';
        }
    }

    handleSubmit(event) {
        event.preventDefault(); 
        const fields = event.detail.fields;

        // Form validation check for lightning-input elements (like Land Duration)
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);

        if (!allValid) {
            this.showToast('Error', 'Please fix validation errors before saving.', 'error');
            return;
        }

        fields.OpportunityId = this.recordId;
        if (this.isLand) {
            fields.Proposed_End_Date__c = this.calculatedEndDate;
            fields.Payment_Terms__c = 4; // Explicitly ensure it's saved as 4
        }

        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSuccess(event) {
        this.showToast('Success', `Quote created successfully: ${event.detail.fields.Name.value}`, 'success');
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleError(event) {
        this.showToast('Error', event.detail.detail, 'error');
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}


