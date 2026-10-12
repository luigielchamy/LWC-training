import { LightningElement, api, wire, track } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRelatedContacts from '@salesforce/apex/accountButtonController.getRelatedContacts';

export default class AccountButton extends LightningElement {
    @api recordId;
    contacts;

    @wire(getRelatedContacts, { accountId: '$recordId' })
    contacts;


    async handleButtonClicked(event) {
        const contactId = event.target.dataset.id;
        console.log("contact Id :",contactId);
        try {
            await deleteRecord(contactId);
            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Contact deleted successfully',
                    variant: 'success'
                })
            );
            
            await refreshApex(this.contacts);
            
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error deleting record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }
    }
}
