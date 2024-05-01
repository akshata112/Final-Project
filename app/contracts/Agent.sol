pragma solidity ^0.5.1;
pragma experimental ABIEncoderV2;

contract Agent {

    struct Precord {
        string ipfshash1;
        string ipfshash2;
        string ipfshash3;
        string ipfshash4;
        string filename;
        uint timeAdded;
    }

    
    struct patient {
        string name;
        uint age;
        string guardian;
        string phonenumber;
        address[] doctorAccessList;
        uint[] diagnosis;
        string record;
    }
    
    struct doctor {
        string name;
        uint age;
        string occupation;
        string phonenumber;
        address[] patientAccessList;
    }

    uint creditPool;

    address[] public patientList;
    address[] public doctorList;

    mapping (address => patient) public patientInfo;
    mapping (address => doctor) public doctorInfo;
    mapping (address => address)public Empty;
    // might not be necessary
    mapping (address => string) public patientRecords;
    mapping (address => Precord[]) public patientDocuments;

    


    function add_agent(string memory _name, uint _age, string memory _guardian, string memory _phonenumber, uint _designation, string memory _hash) public returns(string memory){
        address addr = msg.sender;
        
        if(_designation == 0){
            patient memory p;
            p.name = _name;
            p.age = _age;
            p.guardian=_guardian;
            p.phonenumber=_phonenumber;

            p.record = _hash;
            patientInfo[msg.sender] = p;
            patientList.push(addr)-1;

            return _name;
        }
       else if (_designation == 1){
            doctorInfo[addr].name = _name;
            doctorInfo[addr].age = _age;
            doctorInfo[addr].occupation=_guardian;
            doctorInfo[addr].phonenumber=_phonenumber;
            doctorList.push(addr)-1;
            return _name;
       }
       else{

           revert();
       }
    }


    function get_patient(address addr) public view returns (string memory, uint, string memory, string memory, uint[] memory , address, string memory ){
        // if(keccak256(patientInfo[addr].name) == keccak256(""))revert();
        return (patientInfo[addr].name, patientInfo[addr].age, patientInfo[addr].guardian, patientInfo[addr].phonenumber, patientInfo[addr].diagnosis, Empty[addr], patientInfo[addr].record);
    }

    function get_doctor(address addr) public view returns (string memory, uint, string memory, string memory){
        // if(keccak256(doctorInfo[addr].name)==keccak256(""))revert();
        return (doctorInfo[addr].name, doctorInfo[addr].age, doctorInfo[addr].occupation, doctorInfo[addr].phonenumber);
    }
    function get_patient_doctor_name(address paddr, address daddr) view public returns (string memory , string memory ){
        return (patientInfo[paddr].name,doctorInfo[daddr].name);
    }

    function permit_access(address addr) payable public {
        require(msg.value == 2 ether);

        creditPool += 2;
        
        doctorInfo[addr].patientAccessList.push(msg.sender)-1;
        patientInfo[msg.sender].doctorAccessList.push(addr)-1;
        
    }

    function insurance_claim(address paddr, string memory _diagnosis, string memory  _hash) public {
        bool patientFound = false;
        for(uint i = 0;i<doctorInfo[msg.sender].patientAccessList.length;i++){
            if(doctorInfo[msg.sender].patientAccessList[i]==paddr){
                msg.sender.transfer(2 ether);
                creditPool -= 2;
                patientFound = true;    
            }
        }
        if(patientFound==true){
            set_hash(paddr, _hash);
            remove_patient(paddr, msg.sender);
        }else {
            revert();
        }

    }

    function remove_element_in_array(address[] storage Array, address addr) internal returns(uint)
    {
        bool check = false;
        uint del_index = 0;
        for(uint i = 0; i<Array.length; i++){
            if(Array[i] == addr){
                check = true;
                del_index = i;
            }
        }
        if(!check) revert();
        else{
            if(Array.length == 1){
                delete Array[del_index];
            }
            else {
                Array[del_index] = Array[Array.length - 1];
                delete Array[Array.length - 1];

            }
            Array.length--;
        }
    }

    function remove_patient(address paddr, address daddr) public {
        remove_element_in_array(doctorInfo[daddr].patientAccessList, paddr);
        remove_element_in_array(patientInfo[paddr].doctorAccessList, daddr);
    }
    
    function get_accessed_doctorlist_for_patient(address addr) public view returns (address[] memory )
    { 
        address[] storage doctoraddr = patientInfo[addr].doctorAccessList;
        return doctoraddr;
    }
    function get_accessed_patientlist_for_doctor(address addr) public view returns (address[] memory )
    {
        return doctorInfo[addr].patientAccessList;
    }

    
    function revoke_access(address daddr) public payable{
        remove_patient(msg.sender,daddr);
        msg.sender.transfer(2 ether);
        creditPool -= 2;
    }

    function get_patient_list() public view returns(address[] memory ){
        return patientList;
    }

    function get_doctor_list() public view returns(address[] memory ){
        return doctorList;
    }

    function get_hash(address paddr) public view returns(string memory ){
        return patientInfo[paddr].record;
    }

    function set_hash(address paddr, string memory _hash) internal {
        patientInfo[paddr].record = _hash;
    }

    function addPatientDocument(address patientAddress, string memory _ipfshash1, string memory _ipfshash2, string memory _ipfshash3, string memory _ipfshash4, string memory _filename) public {
        Precord memory p_record=Precord(_ipfshash1,_ipfshash2,_ipfshash3,_ipfshash4,_filename,block.timestamp);
        patientDocuments[patientAddress].push(p_record);
    }

    function getPatientDocuments1(address patientAddress) public view returns (string[] memory) {
        uint256 recordCount = patientDocuments[patientAddress].length;
        string[] memory documents = new string[](recordCount);
        for (uint256 i = 0; i < recordCount; i++) {
            documents[i] = patientDocuments[patientAddress][i].ipfshash1;
        }
        return documents;
    }

    function getPatientDocuments2(address patientAddress) public view returns (string[] memory) {
        uint256 recordCount = patientDocuments[patientAddress].length;
        string[] memory documents = new string[](recordCount);
        for (uint256 i = 0; i < recordCount; i++) {
            documents[i] = patientDocuments[patientAddress][i].ipfshash2;
        }
        return documents;
    }

    function getPatientDocuments3(address patientAddress) public view returns (string[] memory) {
        uint256 recordCount = patientDocuments[patientAddress].length;
        string[] memory documents = new string[](recordCount);
        for (uint256 i = 0; i < recordCount; i++) {
            documents[i] = patientDocuments[patientAddress][i].ipfshash3;
        }
        return documents;
    }

    function getPatientDocuments4(address patientAddress) public view returns (string[] memory) {
        uint256 recordCount = patientDocuments[patientAddress].length;
        string[] memory documents = new string[](recordCount);
        for (uint256 i = 0; i < recordCount; i++) {
            documents[i] = patientDocuments[patientAddress][i].ipfshash4;
        }
        return documents;
    }


    function getPatientDocumentsname(address patientAddress) public view returns (string[] memory) {
        uint256 recordCount = patientDocuments[patientAddress].length;
        string[] memory documents = new string[](recordCount);
        for (uint256 i = 0; i < recordCount; i++) {
            documents[i] = patientDocuments[patientAddress][i].filename;
        }
        return documents;
    }

    function getPatientDocumentstime(address patientAddress) public view returns (uint[] memory) {
        uint256 recordCount = patientDocuments[patientAddress].length;
        uint[] memory documents = new uint[](recordCount);
        for (uint256 i = 0; i < recordCount; i++) {
            documents[i] = patientDocuments[patientAddress][i].timeAdded;
        }
        return documents;
    }
}