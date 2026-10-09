import { LightningElement, api } from 'lwc';

export default class ChildComponent extends LightningElement {
    @api counter = 0;

    // @api
    // addOne() {
    //     this.counter += 1;
    // }
}