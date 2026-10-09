import { LightningElement } from 'lwc';
export default class ParentController extends LightningElement {
    parentCounter = 0;

    handleIncrement() {
        // const childComponent = this.template.querySelector('c-child-component');
        
        // if (childComponent) {
        //     childComponent.addOne();
        // }

        this.parentCounter++;
    }
}
