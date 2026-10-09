import { LightningElement } from 'lwc';

export default class FirstComponent extends LightningElement {
    employees = [
        { id: 1, name: 'John Smith', department: 'IT', position: 'Developer' },
        { id: 2, name: 'Sarah Johnson', department: 'HR', position: 'Recruiter' },
        { id: 3, name: 'Mike Brown', department: 'IT', position: 'QA Engineer' },
        { id: 4, name: 'Emma Davis', department: 'Finance', position: 'Accountant' },
        { id: 5, name: 'Chris Wilson', department: 'HR', position: 'HR Manager' }
    ];

    selectedDepartment = '';
    selectedEmployeeDetails = ''; 

    // Runs automatically when the component is inserted into the DOM
    connectedCallback() {
        if (this.departments.length > 0) {
            this.selectedDepartment = 'Business';
        }
    }

    get departments() {
        const deptSet = new Set(this.employees.map(emp => emp.department));
        return Array.from(deptSet);
    }

    get filteredEmployees() {
        if (!this.selectedDepartment) {
            return this.employees; 
        }
        return this.employees.filter(emp => emp.department === this.selectedDepartment);
    }

    handleDepartmentChange(event) {
        this.selectedDepartment = event.target.value;
        this.selectedEmployeeDetails = ''; 
    }

    handleButtonClick(event) {
        const employeeId = Number(event.currentTarget.dataset.id);
        const targetEmployee = this.employees.find(emp => emp.id === employeeId);
        
        if (targetEmployee) { 
            const textDetail = this.template.querySelector('.details');
            textDetail.style.visibility = 'visible';

            this.selectedEmployeeDetails = `Name: ${targetEmployee.name}\nDepartment: ${targetEmployee.department}\nPosition: ${targetEmployee.position}\nID: ${targetEmployee.id}`; 
        }
    }
}
