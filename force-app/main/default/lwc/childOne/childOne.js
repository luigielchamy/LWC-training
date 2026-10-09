import { LightningElement } from 'lwc';

export default class ChildOne extends LightningElement {
    isSelected = false;

    get buttonVariant() {
        return this.isSelected ? 'destructive' : 'brand';
    }

    get buttonLabel() {
        return this.isSelected ? 'Diselected' : 'Selected';
    }

    handleClick() {
        this.isSelected = !this.isSelected; 

        const sendParent = new CustomEvent('statuschange', {
            detail: this.isSelected
        });

        this.dispatchEvent(sendParent);
    }

}