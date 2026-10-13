import { LightningElement, wire, track } from 'lwc';
import getAccountsWithOpportunities from '@salesforce/apex/AccountOpportunityController.getAccountsWithOpportunities';
import updateOpportunityStage from '@salesforce/apex/AccountOpportunityController.updateOpportunityStage';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MonitorComponent extends LightningElement {
    @track accountsData;
    @track error;
    wireResult;

    isModalOpen = false;
    selectedOppId = '';
    selectedOppName = '';
    selectedStage = '';

    stageOptions = [
        { label: 'Closed Won', value: 'Closed Won' },
        { label: 'Closed Lost', value: 'Closed Lost' }
    ];

    @wire(getAccountsWithOpportunities)
    wiredAccounts(result) {
        this.wireResult = result;
        if (result.data) {
            this.accountsData = result.data.map(acc => {
                const formattedOpps = (acc.opportunities || []).map(opp => ({
                    ...opp,
                    isClosed: opp.StageName === 'Closed Won' || opp.StageName === 'Closed Lost'
                }));
                return {
                    ...acc,
                    opportunities: formattedOpps,
                    hasOpportunities: formattedOpps.length > 0,
                    sectionLabel: `${acc.accountName} (${acc.opportunityCount} Opportunities | Total: $${acc.totalAmount || 0})`
                };
            });
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.accountsData = undefined;
        }
    }

    handleOpenModal(event) {
        this.selectedOppId = event.target.dataset.id;
        this.selectedOppName = event.target.dataset.name;
        this.selectedStage = '';
        this.isModalOpen = true;
    }

    handleCloseModal() {
        this.isModalOpen = false;
        this.selectedOppId = '';
        this.selectedOppName = '';
        this.selectedStage = '';
    }

    handleStageChange(event) {
        this.selectedStage = event.detail.value;
    }

    get isUpdateDisabled() {
        return !this.selectedStage;
    }

    handleUpdateOpportunity() {
        updateOpportunityStage({
            opportunityId: this.selectedOppId,
            newStage: this.selectedStage
        })
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Opportunity stage updated successfully.',
                    variant: 'success'
                })
            );
            this.handleCloseModal();
            return refreshApex(this.wireResult);
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating opportunity',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }
}
