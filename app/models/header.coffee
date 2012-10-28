Model = require 'models/base/model'

module.exports = class Header extends Model
  defaults:
    items: [
      {href: './test/', title: 'App Tests'},
      {href: 'https://github.com/martar/optimal-gigant', title: 'Repo'},
    ]
