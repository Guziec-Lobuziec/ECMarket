pragma solidity 0.4.23;


contract BasicRatings {

    mapping (address => uint) basicRating;

    function getRating(address ratingSystem) public view returns (uint rating) {
        return basicRating[ratingSystem];
    }
}
