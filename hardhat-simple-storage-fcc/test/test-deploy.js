const { ethers } = require("hardhat");
const { expect, assert } = require("chai");

describe("SimpleStorage", () => {
  let simpleStorageFactory, simpleStorage;

  beforeEach(async function () {
    simpleStorageFactory = await ethers.getContractFactory("SimpleStorage");
    simpleStorage = await simpleStorageFactory.deploy();
  });

  it("Should start with a favorite number of 0", async function () {
    const currentValue = await simpleStorage.retrieve();
    const expectedValue = "0";
    // assert
    // except
    assert.equal(currentValue.toString(), expectedValue);
    // Same thing with expect
    // expect(currentValue.toString()).to.equal(expectedValue);
  });
  it("Should update when we call store", async function () {
    const expectedValue = "7";
    const transactionResponse = await simpleStorage.store(expectedValue);
    await transactionResponse.wait(1);

    const currentValue = await simpleStorage.retrieve();
    assert.equal(currentValue.toString(), expectedValue);
  });

  it("Should add person when we call addPerson", async function () {
    const expectedPerson = "John";
    const expectedNumber = "5";
    const transactionResponse = await simpleStorage.addPerson(
      expectedPerson,
      expectedNumber
    );
    await transactionResponse.wait(1);

    const { favoriteNumber, name } = await simpleStorage.people(0);
    assert.equal(name, expectedPerson);
    assert.equal(favoriteNumber, expectedNumber);
  });
});
