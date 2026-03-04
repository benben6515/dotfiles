const add = (a, b) => a + b

// person object
class Pserson {
  constructor(name) {
    this.name = name
  }

  sayHi = () => console.log(`Hi, ${this.name}`)
}

// TODO:
const benben = new Pserson('benben')

benben.sayHi()
