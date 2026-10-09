import { LightningElement, wire } from 'lwc';
import createNewAccount from '@salesforce/apex/AccountController.createNewAccount';
import getAccounts from '@salesforce/apex/AccountController.getAccounts';
import {NavigationMixin} from 'lightning/navigation';

export default class CreateAccount extends NavigationMixin(LightningElement) {
    accountName;
    accounts;
    maxRecords = 10;
    errors;

    handlechange(event){
        this.accountName = event.target.value;
    }

    handleClick(){
        createNewAccount({accountName:this.accountName}).then(result=>{
            console.log('Result is:', result);
        }).catch(error=>{
            console.log('error occured when inserting account :',error);
        })

    }

    @wire(getAccounts, {maxRecords:"$maxRecords"}) 
    wired_getMethod({errors, data}) {
        if(data) {
            this.accounts = data;
            this.errors = undefined;
        } else if(errors) {
            this.accounts = undefined;
            this.errors = errors;
        }
    }


    
}