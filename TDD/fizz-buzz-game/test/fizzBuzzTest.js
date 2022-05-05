const expected = require('chai').expect;
const fizzBuzz = require('./fizzBuzz.js');

describe('Fizz Buzz Game', () => {
    it('Return number 1', () => {
        expected(fizzBuzz(1)).to.equal(1);
    })

    it('Return number 2', () => {
        expected(fizzBuzz(2)).to.equal(2);
    })

    it('Return "Fizz" for 3', () => {
        expected(fizzBuzz(3)).to.equal("Fizz");
    })

    it('Return "Fizz" for multiples of 3', () => {
        expected(fizzBuzz(6)).to.equal("Fizz");
    })

    it('Return "Buzz" for 5', () => {
        expected(fizzBuzz(5)).to.equal("Buzz");
    })

    it('Return "Buzz" for multiples of 5', () => {
        expected(fizzBuzz(10)).to.equal("Buzz");
    })

    it('Return "FizzBuzz" for multiples of 3 & 5 when is 15', () => {
        expected(fizzBuzz(15)).to.equal("FizzBuzz");
    })

})