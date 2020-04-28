pragma solidity ^0.6.4;


contract Loan {
    address payable clientWallet;
    address payable bankWallet;
    uint256 loanStartDate;
    uint256 interestRatePerAnnum;
    uint256 loanPeriodInYears;
    uint256 loanAmount;
    bool loanDisbursed = false;
    bool loanPaid = false;

    constructor(
        address payable _clientWallet,
        uint256 _loanAmount,
        uint256 _loanStartDate,
        uint256 _interestRatePerAnnum,
        uint256 _loanPeriodInYears
    ) public {
        clientWallet = _clientWallet;
        bankWallet = msg.sender;
        loanAmount = _loanAmount;
        loanStartDate = _loanStartDate;
        interestRatePerAnnum = _interestRatePerAnnum;
        loanPeriodInYears = _loanPeriodInYears;
    }

    //Modifier for the Bank - this means that Bank alone can execute the associated function
    modifier onlyBank() {
        require(
            bankWallet == msg.sender,
            "Only Bank can execute this Smart Contract"
        );
        _;
    }

    //Mofidier for the Loan Start Date
    modifier onlyAtTheStartDate() {
        require(
            block.timestamp >= loanStartDate,
            "Can be executed on or after the Loan Start Date"
        );
        _;
    }

    //Modifier for the Bank - this means that Client alone can execute the associated function
    modifier onlyClient() {
        require(
            clientWallet == msg.sender,
            "Client alone can execute this Smart Contract"
        );
        _;
    }

    //Event for Tranfer
    event Transfer(address _sender, uint256 _quantity, address _receiver);

    //Event for Loan Disburse
    event Disburse(uint256 _msgAmount, uint256 _loanAmount);

    //interestAmount
    function interestAmount() internal view returns (uint256) {
        return (loanAmount * loanPeriodInYears * interestRatePerAnnum) / 100;
    }

    //Disburse Amount Valid?
    function disbusedAmountValid(uint256 _value) internal returns (bool) {
        emit Disburse(_value, loanAmount * 1e18);
        return (_value == loanAmount * 1e18);
    }

    //Loan Paymet  Amount Valid?
    function paymentAmountValid(uint256 _value) internal returns (bool) {
        emit Disburse(_value, loanMaturityAmount());
        return (_value == loanMaturityAmount() * 1e18);
    }

    //Repayment Amount
    function loanMaturityAmount() public view returns (uint256) {
        require(loanDisbursed == true, "Loan is not disbursed yet");
        if (isLoanPaid()) {
            return 0;
        } else {
            return (loanAmount + interestAmount());
        }
    }

    //Is Loan Disbursed?
    function isLoanDisbursed() internal view returns (bool) {
        return loanDisbursed == true;
    }

    //Is Loan Repaid?
    function isLoanPaid() internal view returns (bool) {
        return loanPaid == true;
    }

    //Function for disbursing the Loan
    function disburseLoan() public payable onlyBank onlyAtTheStartDate {
        require(
            loanDisbursed == false && disbusedAmountValid(msg.value),
            "Disbursed Loan amount should be equal to the Loan Amount"
        );
        clientWallet.transfer(msg.value);
        loanDisbursed = true;

        emit Transfer(msg.sender, msg.value, clientWallet);
    }

    //Function for Loan Payment
    function payLoan() public payable onlyClient {
        require(
            loanDisbursed == true &&
                loanPaid == false &&
                paymentAmountValid(msg.value),
            "Loan can only be paid with the Maturity Amount once after it is disbursed"
        );
        bankWallet.transfer(msg.value);
        loanPaid = true;
        emit Transfer(msg.sender, msg.value, bankWallet);
    }
}
