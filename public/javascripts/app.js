(function(/*! Brunch !*/) {
  'use strict';

  var globals = typeof window !== 'undefined' ? window : global;
  if (typeof globals.require === 'function') return;

  var modules = {};
  var cache = {};

  var has = function(object, name) {
    return ({}).hasOwnProperty.call(object, name);
  };

  var expand = function(root, name) {
    var results = [], parts, part;
    if (/^\.\.?(\/|$)/.test(name)) {
      parts = [root, name].join('/').split('/');
    } else {
      parts = name.split('/');
    }
    for (var i = 0, length = parts.length; i < length; i++) {
      part = parts[i];
      if (part === '..') {
        results.pop();
      } else if (part !== '.' && part !== '') {
        results.push(part);
      }
    }
    return results.join('/');
  };

  var dirname = function(path) {
    return path.split('/').slice(0, -1).join('/');
  };

  var localRequire = function(path) {
    return function(name) {
      var dir = dirname(path);
      var absolute = expand(dir, name);
      return globals.require(absolute);
    };
  };

  var initModule = function(name, definition) {
    var module = {id: name, exports: {}};
    definition(module.exports, localRequire(name), module);
    var exports = cache[name] = module.exports;
    return exports;
  };

  var require = function(name) {
    var path = expand(name, '.');

    if (has(cache, path)) return cache[path];
    if (has(modules, path)) return initModule(path, modules[path]);

    var dirIndex = expand(path, './index');
    if (has(cache, dirIndex)) return cache[dirIndex];
    if (has(modules, dirIndex)) return initModule(dirIndex, modules[dirIndex]);

    throw new Error('Cannot find module "' + name + '"');
  };

  var define = function(bundle) {
    for (var key in bundle) {
      if (has(bundle, key)) {
        modules[key] = bundle[key];
      }
    }
  }

  globals.require = require;
  globals.require.define = define;
  globals.require.brunch = true;
})();

window.require.define({"application": function(exports, require, module) {
  var Application, Chaplin, HeaderController, Layout, SessionController, mediator, routes,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Chaplin = require('chaplin');

  mediator = require('mediator');

  routes = require('routes');

  SessionController = require('controllers/session_controller');

  HeaderController = require('controllers/header_controller');

  Layout = require('views/layout');

  module.exports = Application = (function(_super) {

    __extends(Application, _super);

    function Application() {
      return Application.__super__.constructor.apply(this, arguments);
    }

    Application.prototype.title = 'Brunch example application';

    Application.prototype.initialize = function() {
      Application.__super__.initialize.apply(this, arguments);
      this.initDispatcher();
      this.initLayout();
      this.initMediator();
      this.initControllers();
      this.initRouter(routes);
      return typeof Object.freeze === "function" ? Object.freeze(this) : void 0;
    };

    Application.prototype.initLayout = function() {
      return this.layout = new Layout({
        title: this.title
      });
    };

    Application.prototype.initControllers = function() {
      new SessionController();
      return new HeaderController();
    };

    Application.prototype.initMediator = function() {
      mediator.user = null;
      return mediator.seal();
    };

    return Application;

  })(Chaplin.Application);
  
}});

window.require.define({"controllers/base/controller": function(exports, require, module) {
  var Chaplin, Controller,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Chaplin = require('chaplin');

  module.exports = Controller = (function(_super) {

    __extends(Controller, _super);

    function Controller() {
      return Controller.__super__.constructor.apply(this, arguments);
    }

    return Controller;

  })(Chaplin.Controller);
  
}});

window.require.define({"controllers/header_controller": function(exports, require, module) {
  var Controller, Header, HeaderController, HeaderView,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Controller = require('controllers/base/controller');

  Header = require('models/header');

  HeaderView = require('views/header_view');

  module.exports = HeaderController = (function(_super) {

    __extends(HeaderController, _super);

    function HeaderController() {
      return HeaderController.__super__.constructor.apply(this, arguments);
    }

    HeaderController.prototype.initialize = function() {
      HeaderController.__super__.initialize.apply(this, arguments);
      this.model = new Header();
      return this.view = new HeaderView({
        model: this.model
      });
    };

    return HeaderController;

  })(Controller);
  
}});

window.require.define({"controllers/home_controller": function(exports, require, module) {
  var Controller, HomeController, HomePageView, ProblemModel,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Controller = require('controllers/base/controller');

  HomePageView = require('views/home_page_view');

  ProblemModel = require('models/problem');

  module.exports = HomeController = (function(_super) {

    __extends(HomeController, _super);

    function HomeController() {
      return HomeController.__super__.constructor.apply(this, arguments);
    }

    HomeController.prototype.historyURL = 'home';

    HomeController.prototype.index = function() {
      this.problem = new ProblemModel();
      return this.view = new HomePageView(this.problem);
    };

    return HomeController;

  })(Controller);
  
}});

window.require.define({"controllers/session_controller": function(exports, require, module) {
  var Controller, LoginView, SessionController, User, mediator,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  mediator = require('mediator');

  Controller = require('controllers/base/controller');

  User = require('models/user');

  LoginView = require('views/login_view');

  module.exports = SessionController = (function(_super) {

    __extends(SessionController, _super);

    function SessionController() {
      this.logout = __bind(this.logout, this);

      this.serviceProviderSession = __bind(this.serviceProviderSession, this);

      this.triggerLogin = __bind(this.triggerLogin, this);
      return SessionController.__super__.constructor.apply(this, arguments);
    }

    SessionController.serviceProviders = {};

    SessionController.prototype.loginStatusDetermined = false;

    SessionController.prototype.loginView = null;

    SessionController.prototype.serviceProviderName = null;

    SessionController.prototype.initialize = function() {
      this.subscribeEvent('serviceProviderSession', this.serviceProviderSession);
      this.subscribeEvent('logout', this.logout);
      this.subscribeEvent('userData', this.userData);
      this.subscribeEvent('!showLogin', this.showLoginView);
      this.subscribeEvent('!login', this.triggerLogin);
      this.subscribeEvent('!logout', this.triggerLogout);
      return this.getSession();
    };

    SessionController.prototype.loadServiceProviders = function() {
      var name, serviceProvider, _ref, _results;
      _ref = SessionController.serviceProviders;
      _results = [];
      for (name in _ref) {
        serviceProvider = _ref[name];
        _results.push(serviceProvider.load());
      }
      return _results;
    };

    SessionController.prototype.createUser = function(userData) {
      return mediator.user = new User(userData);
    };

    SessionController.prototype.getSession = function() {
      var name, serviceProvider, _ref, _results;
      this.loadServiceProviders();
      _ref = SessionController.serviceProviders;
      _results = [];
      for (name in _ref) {
        serviceProvider = _ref[name];
        _results.push(serviceProvider.done(serviceProvider.getLoginStatus));
      }
      return _results;
    };

    SessionController.prototype.showLoginView = function() {
      if (this.loginView) {
        return;
      }
      this.loadServiceProviders();
      return this.loginView = new LoginView({
        serviceProviders: SessionController.serviceProviders
      });
    };

    SessionController.prototype.triggerLogin = function(serviceProviderName) {
      var serviceProvider;
      serviceProvider = SessionController.serviceProviders[serviceProviderName];
      if (!serviceProvider.isLoaded()) {
        this.publishEvent('serviceProviderMissing', serviceProviderName);
        return;
      }
      this.publishEvent('loginAttempt', serviceProviderName);
      return serviceProvider.triggerLogin();
    };

    SessionController.prototype.serviceProviderSession = function(session) {
      this.serviceProviderName = session.provider.name;
      this.disposeLoginView();
      session.id = session.userId;
      delete session.userId;
      this.createUser(session);
      return this.publishLogin();
    };

    SessionController.prototype.publishLogin = function() {
      this.loginStatusDetermined = true;
      this.publishEvent('login', mediator.user);
      return this.publishEvent('loginStatus', true);
    };

    SessionController.prototype.triggerLogout = function() {
      return this.publishEvent('logout');
    };

    SessionController.prototype.logout = function() {
      this.loginStatusDetermined = true;
      this.disposeUser();
      this.serviceProviderName = null;
      this.showLoginView();
      return this.publishEvent('loginStatus', false);
    };

    SessionController.prototype.userData = function(data) {
      return mediator.user.set(data);
    };

    SessionController.prototype.disposeLoginView = function() {
      if (!this.loginView) {
        return;
      }
      this.loginView.dispose();
      return this.loginView = null;
    };

    SessionController.prototype.disposeUser = function() {
      if (!mediator.user) {
        return;
      }
      mediator.user.dispose();
      return mediator.user = null;
    };

    return SessionController;

  })(Controller);
  
}});

window.require.define({"initialize": function(exports, require, module) {
  var Application;

  Application = require('application');

  $(document).on('ready', function() {
    var app;
    app = new Application();
    return app.initialize();
  });
  
}});

window.require.define({"lib/services/service_provider": function(exports, require, module) {
  var Chaplin, ServiceProvider, utils;

  utils = require('lib/utils');

  Chaplin = require('chaplin');

  module.exports = ServiceProvider = (function() {

    _(ServiceProvider.prototype).extend(Chaplin.EventBroker);

    ServiceProvider.prototype.loading = false;

    function ServiceProvider() {
      _(this).extend($.Deferred());
      utils.deferMethods({
        deferred: this,
        methods: ['triggerLogin', 'getLoginStatus'],
        onDeferral: this.load
      });
    }

    ServiceProvider.prototype.disposed = false;

    ServiceProvider.prototype.dispose = function() {
      if (this.disposed) {
        return;
      }
      this.unsubscribeAllEvents();
      this.disposed = true;
      return typeof Object.freeze === "function" ? Object.freeze(this) : void 0;
    };

    return ServiceProvider;

  })();

  /*

    Standard methods and their signatures:

    load: ->
      # Load a script like this:
      utils.loadLib 'http://example.org/foo.js', @loadHandler, @reject

    loadHandler: =>
      # Init the library, then resolve
      ServiceProviderLibrary.init(foo: 'bar')
      @resolve()

    isLoaded: ->
      # Return a Boolean
      Boolean window.ServiceProviderLibrary and ServiceProviderLibrary.login

    # Trigger login popup
    triggerLogin: (loginContext) ->
      callback = _(@loginHandler).bind(this, loginContext)
      ServiceProviderLibrary.login callback

    # Callback for the login popup
    loginHandler: (loginContext, response) =>

      eventPayload = {provider: this, loginContext}
      if response
        # Publish successful login
        @publishEvent 'loginSuccessful', eventPayload

        # Publish the session
        @publishEvent 'serviceProviderSession',
          provider: this
          userId: response.userId
          accessToken: response.accessToken
          # etc.

      else
        @publishEvent 'loginFail', eventPayload

    getLoginStatus: (callback = @loginStatusHandler, force = false) ->
      ServiceProviderLibrary.getLoginStatus callback, force

    loginStatusHandler: (response) =>
      return unless response
      @publishEvent 'serviceProviderSession',
        provider: this
        userId: response.userId
        accessToken: response.accessToken
        # etc.
  */

  
}});

window.require.define({"lib/support": function(exports, require, module) {
  var Chaplin, support, utils;

  Chaplin = require('chaplin');

  utils = require('lib/utils');

  support = utils.beget(Chaplin.support);

  module.exports = support;
  
}});

window.require.define({"lib/utils": function(exports, require, module) {
  var Chaplin, utils,
    __hasProp = {}.hasOwnProperty;

  Chaplin = require('chaplin');

  utils = Chaplin.utils.beget(Chaplin.utils);

  _(utils).extend({
    /*
      Wrap methods so they can be called before a deferred is resolved.
      The actual methods are called once the deferred is resolved.
    
      Parameters:
    
      Expects an options hash with the following properties:
    
      deferred
        The Deferred object to wait for.
    
      methods
        Either:
        - A string with a method name e.g. 'method'
        - An array of strings e.g. ['method1', 'method2']
        - An object with methods e.g. {method: -> alert('resolved!')}
    
      host (optional)
        If you pass an array of strings in the `methods` parameter the methods
        are fetched from this object. Defaults to `deferred`.
    
      target (optional)
        The target object the new wrapper methods are created at.
        Defaults to host if host is given, otherwise it defaults to deferred.
    
      onDeferral (optional)
        An additional callback function which is invoked when the method is called
        and the Deferred isn't resolved yet.
        After the method is registered as a done handler on the Deferred,
        this callback is invoked. This can be used to trigger the resolving
        of the Deferred.
    
      Examples:
    
      deferMethods(deferred: def, methods: 'foo')
        Wrap the method named foo of the given deferred def and
        postpone all calls until the deferred is resolved.
    
      deferMethods(deferred: def, methods: def.specialMethods)
        Read all methods from the hash def.specialMethods and
        create wrapped methods with the same names at def.
    
      deferMethods(
        deferred: def, methods: def.specialMethods, target: def.specialMethods
      )
        Read all methods from the object def.specialMethods and
        create wrapped methods at def.specialMethods,
        overwriting the existing ones.
    
      deferMethods(deferred: def, host: obj, methods: ['foo', 'bar'])
        Wrap the methods obj.foo and obj.bar so all calls to them are postponed
        until def is resolved. obj.foo and obj.bar are overwritten
        with their wrappers.
    */

    deferMethods: function(options) {
      var deferred, func, host, methods, methodsHash, name, onDeferral, target, _i, _len, _results;
      deferred = options.deferred;
      methods = options.methods;
      host = options.host || deferred;
      target = options.target || host;
      onDeferral = options.onDeferral;
      methodsHash = {};
      if (typeof methods === 'string') {
        methodsHash[methods] = host[methods];
      } else if (methods.length && methods[0]) {
        for (_i = 0, _len = methods.length; _i < _len; _i++) {
          name = methods[_i];
          func = host[name];
          if (typeof func !== 'function') {
            throw new TypeError("utils.deferMethods: method " + name + " notfound on host " + host);
          }
          methodsHash[name] = func;
        }
      } else {
        methodsHash = methods;
      }
      _results = [];
      for (name in methodsHash) {
        if (!__hasProp.call(methodsHash, name)) continue;
        func = methodsHash[name];
        if (typeof func !== 'function') {
          continue;
        }
        _results.push(target[name] = utils.createDeferredFunction(deferred, func, target, onDeferral));
      }
      return _results;
    },
    createDeferredFunction: function(deferred, func, context, onDeferral) {
      if (context == null) {
        context = deferred;
      }
      return function() {
        var args;
        args = arguments;
        if (deferred.state() === 'resolved') {
          return func.apply(context, args);
        } else {
          deferred.done(function() {
            return func.apply(context, args);
          });
          if (typeof onDeferral === 'function') {
            return onDeferral.apply(context);
          }
        }
      };
    }
  });

  module.exports = utils;
  
}});

window.require.define({"lib/view_helper": function(exports, require, module) {
  var mediator, utils;

  mediator = require('mediator');

  utils = require('chaplin/lib/utils');

  Handlebars.registerHelper('if_logged_in', function(options) {
    if (mediator.user) {
      return options.fn(this);
    } else {
      return options.inverse(this);
    }
  });

  Handlebars.registerHelper('with', function(context, options) {
    if (!context || Handlebars.Utils.isEmpty(context)) {
      return options.inverse(this);
    } else {
      return options.fn(context);
    }
  });

  Handlebars.registerHelper('without', function(context, options) {
    var inverse;
    inverse = options.inverse;
    options.inverse = options.fn;
    options.fn = inverse;
    return Handlebars.helpers["with"].call(this, context, options);
  });

  Handlebars.registerHelper('with_user', function(options) {
    var context;
    context = mediator.user || {};
    return Handlebars.helpers["with"].call(this, context, options);
  });
  
}});

window.require.define({"mediator": function(exports, require, module) {
  
  module.exports = require('chaplin').mediator;
  
}});

window.require.define({"models/base/collection": function(exports, require, module) {
  var Chaplin, Collection,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Chaplin = require('chaplin');

  module.exports = Collection = (function(_super) {

    __extends(Collection, _super);

    function Collection() {
      return Collection.__super__.constructor.apply(this, arguments);
    }

    return Collection;

  })(Chaplin.Collection);
  
}});

window.require.define({"models/base/model": function(exports, require, module) {
  var Chaplin, Model,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Chaplin = require('chaplin');

  module.exports = Model = (function(_super) {

    __extends(Model, _super);

    function Model() {
      return Model.__super__.constructor.apply(this, arguments);
    }

    return Model;

  })(Chaplin.Model);
  
}});

window.require.define({"models/header": function(exports, require, module) {
  var Header, Model,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Model = require('models/base/model');

  module.exports = Header = (function(_super) {

    __extends(Header, _super);

    function Header() {
      return Header.__super__.constructor.apply(this, arguments);
    }

    Header.prototype.defaults = {
      items: [
        {
          href: './test/',
          title: 'App Tests'
        }, {
          href: 'https://github.com/martar/optimal-gigant',
          title: 'Repo'
        }
      ]
    };

    return Header;

  })(Model);
  
}});

window.require.define({"models/problem": function(exports, require, module) {
  var Model, Problem, SERVER_URL,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Model = require('models/base/model');

  SERVER_URL = 'http://localhost:5000/';

  module.exports = Problem = (function(_super) {

    __extends(Problem, _super);

    function Problem() {
      this.postResult = __bind(this.postResult, this);

      this.getBestResult = __bind(this.getBestResult, this);

      this.load = __bind(this.load, this);
      return Problem.__super__.constructor.apply(this, arguments);
    }

    Problem.prototype.defaults = {
      title: '',
      completed: false
    };

    Problem.prototype.initialize = function() {
      Problem.__super__.initialize.apply(this, arguments);
      if (this.isNew()) {
        return this.set('created', Date.now());
      }
    };

    Problem.prototype.load = function(onSuccess) {
      var _this = this;
      return $.ajax({
        type: 'GET',
        url: SERVER_URL + "slalom",
        dataType: "json",
        success: function(data) {
          _this.set(data);
          return onSuccess(data);
        },
        error: function(evt) {
          return console.dir("[Client][REST]  Error getting the prolem instance: " + evt);
        }
      });
    };

    Problem.prototype.getBestResult = function(onSuccess) {
      var _this = this;
      return $.ajax({
        type: 'GET',
        url: SERVER_URL + "result/" + this.get('_id'),
        dataType: "json",
        success: function(data) {
          console.dir("[Client][REST]  Success getting the best result");
          return onSuccess(data.bestTimeInDb);
        },
        error: function(evt) {
          console.dir("[Client][REST]  Error getting the best result:");
          return console.dir(evt);
        }
      });
    };

    Problem.prototype.postResult = function(result, onSuccess) {
      return $.ajax({
        type: 'POST',
        url: SERVER_URL + "slalom",
        data: result,
        dataType: "json",
        ContentType: "application/json; charset=UTF-8",
        success: function(data) {
          console.dir(data);
          return onSuccess(data);
        },
        error: function(evt) {
          return console.dir("[Client][REST] Error posting the result: " + evt);
        }
      });
    };

    return Problem;

  })(Model);
  
}});

window.require.define({"models/user": function(exports, require, module) {
  var Model, User,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Model = require('models/base/model');

  module.exports = User = (function(_super) {

    __extends(User, _super);

    function User() {
      return User.__super__.constructor.apply(this, arguments);
    }

    return User;

  })(Model);
  
}});

window.require.define({"routes": function(exports, require, module) {
  
  module.exports = function(match) {
    return match('', 'home#index');
  };
  
}});

window.require.define({"views/base/collection_view": function(exports, require, module) {
  var Chaplin, CollectionView, View,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Chaplin = require('chaplin');

  View = require('views/base/view');

  module.exports = CollectionView = (function(_super) {

    __extends(CollectionView, _super);

    function CollectionView() {
      return CollectionView.__super__.constructor.apply(this, arguments);
    }

    CollectionView.prototype.getTemplateFunction = View.prototype.getTemplateFunction;

    return CollectionView;

  })(Chaplin.CollectionView);
  
}});

window.require.define({"views/base/page_view": function(exports, require, module) {
  var PageView, View,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  View = require('views/base/view');

  module.exports = PageView = (function(_super) {

    __extends(PageView, _super);

    function PageView() {
      return PageView.__super__.constructor.apply(this, arguments);
    }

    PageView.prototype.container = '#page-container';

    PageView.prototype.autoRender = true;

    PageView.prototype.renderedSubviews = false;

    PageView.prototype.initialize = function() {
      var rendered,
        _this = this;
      PageView.__super__.initialize.apply(this, arguments);
      if (this.model || this.collection) {
        rendered = false;
        return this.modelBind('change', function() {
          if (!rendered) {
            _this.render();
          }
          return rendered = true;
        });
      }
    };

    PageView.prototype.renderSubviews = function() {};

    PageView.prototype.render = function() {
      PageView.__super__.render.apply(this, arguments);
      if (!this.renderedSubviews) {
        this.renderSubviews();
        return this.renderedSubviews = true;
      }
    };

    return PageView;

  })(View);
  
}});

window.require.define({"views/base/view": function(exports, require, module) {
  var Chaplin, View,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Chaplin = require('chaplin');

  require('lib/view_helper');

  module.exports = View = (function(_super) {

    __extends(View, _super);

    function View() {
      return View.__super__.constructor.apply(this, arguments);
    }

    View.prototype.getTemplateFunction = function() {
      return this.template;
    };

    return View;

  })(Chaplin.View);
  
}});

window.require.define({"views/header_view": function(exports, require, module) {
  var HeaderView, View, template,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  View = require('views/base/view');

  template = require('views/templates/header');

  module.exports = HeaderView = (function(_super) {

    __extends(HeaderView, _super);

    function HeaderView() {
      return HeaderView.__super__.constructor.apply(this, arguments);
    }

    HeaderView.prototype.template = template;

    HeaderView.prototype.id = 'header';

    HeaderView.prototype.className = 'header';

    HeaderView.prototype.container = '#header-container';

    HeaderView.prototype.autoRender = true;

    HeaderView.prototype.initialize = function() {
      HeaderView.__super__.initialize.apply(this, arguments);
      this.subscribeEvent('loginStatus', this.render);
      return this.subscribeEvent('startupController', this.render);
    };

    return HeaderView;

  })(View);
  
}});

window.require.define({"views/home_page_view": function(exports, require, module) {
  var HomePageView, PageView, dataGen, fu, general_chart, template, zip,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  template = require('views/templates/home');

  PageView = require('views/base/page_view');

  /*
  This is stupid. But without some set of initial data, the chart doesn't update well later on
  */


  dataGen = function() {
    var data, i, time, _i;
    data = [];
    time = (new Date()).getTime();
    for (i = _i = -19; _i <= 0; i = _i += 1) {
      data.push({
        x: time + i * 1000,
        y: 11
      });
    }
    return data;
  };

  general_chart = function(avg, best, worst) {
    var general;
    return general = new Highcharts.Chart({
      chart: {
        renderTo: 'general_stats_container',
        type: 'spline',
        marginRight: 10
      },
      title: {
        text: 'Overall fitness of the population'
      },
      xAxis: {
        type: 'datetime',
        tickPixelInterval: 150
      },
      yAxis: {
        title: {
          text: 'Value'
        },
        plotLines: [
          {
            value: 0,
            width: 1,
            color: '#808080'
          }, {
            value: 0,
            width: 1,
            color: 'red'
          }, {
            value: 0,
            width: 1,
            color: 'yellow'
          }
        ]
      },
      legend: {
        enabled: true
      },
      exporting: {
        enabled: false
      },
      series: [
        {
          name: 'AverageFitness',
          data: avg
        }, {
          name: 'Best Fitness',
          data: best
        }, {
          name: 'Worst Fitness',
          data: worst
        }
      ]
    });
  };

  fu = function() {
    var chart;
    chart = new Highcharts.Chart({
      chart: {
        renderTo: 'stats_container',
        type: 'spline',
        marginRight: 10
      },
      title: {
        text: 'Fitness of the population'
      },
      xAxis: {
        type: 'datetime',
        tickPixelInterval: 150
      },
      yAxis: {
        title: {
          text: 'Value'
        },
        plotLines: [
          {
            value: 0,
            width: 1,
            color: '#808080'
          }, {
            value: 0,
            width: 1,
            color: 'red'
          }, {
            value: 0,
            width: 1,
            color: 'yellow'
          }
        ]
      },
      legend: {
        enabled: true
      },
      exporting: {
        enabled: false
      },
      series: [
        {
          name: 'AverageFitness',
          data: dataGen()
        }, {
          name: 'Best Fitness',
          data: dataGen()
        }, {
          name: 'Worst Fitness',
          data: dataGen()
        }
      ]
    });
    return chart;
  };

  module.exports = HomePageView = (function(_super) {
    var transX, transY;

    __extends(HomePageView, _super);

    HomePageView.prototype.template = template;

    HomePageView.prototype.className = 'home-page';

    function HomePageView(problem) {
      this.problem = problem;
      this.work = __bind(this.work, this);

      this.processStatistics = __bind(this.processStatistics, this);

      this.renderResults = __bind(this.renderResults, this);

      this.drawGates = __bind(this.drawGates, this);

      this.drawIntermediate = __bind(this.drawIntermediate, this);

      this.draw = __bind(this.draw, this);

      this.afterRender = __bind(this.afterRender, this);

      this.onSuccess = __bind(this.onSuccess, this);

      HomePageView.__super__.constructor.apply(this, arguments);
    }

    HomePageView.prototype.onSuccess = function(result) {
      this.problemId = this.problem.attributes._id;
      this.giantGates = this.problem.attributes.giantGates;
      this.closedGates = this.problem.attributes.closedGates;
      this.hasLeftSidePollGates = this.problem.attributes.hasLeftSidePollGates;
      return this.work();
    };

    HomePageView.prototype.afterRender = function() {
      var _this = this;
      HomePageView.__super__.afterRender.apply(this, arguments);
      console.dir(this.problem);
      this.toggle = true;
      this.canvas = this.$('#slope').get(0);
      this.getProblemButton = this.$('#get-problem-button');
      this.dancers = this.$('#dancers');
      this.success = this.$('#success');
      this.nsolved = this.$('#nsolved');
      this.bestWeHave = this.$('#bestWeHave');
      this.bestYouFound = this.$('#bestYouFound');
      this.bestTimeUserFound = null;
      this.musicoff = this.$('#musicoff');
      this.musicoff.click(function() {
        return _this.$('#game').remove();
      });
      this.numberOfSolved = 0;
      this.computationContainer = this.$('#computation');
      this.getProblemButton.click(function() {
        _this.problem.load(_this.onSuccess);
        return _this.success.hide();
      });
      this.context = this.canvas.getContext('2d');
      this.worker = new Worker('javascripts/turnWorker.js');
      this.avgFitness = [[]];
      this.bestFitness = [[]];
      this.worstFitness = [[]];
      this.chart = fu();
      return Highcharts.setOptions({
        global: {
          useUTC: false
        }
      });
    };

    transX = function(coord) {
      return Math.round(coord * 10 + 175);
    };

    transY = function(coord) {
      return Math.round(coord * 10 + 100);
    };

    HomePageView.prototype.draw = function(data) {
      var pair, skier, x, y, _i, _j, _len, _len1, _ref, _ref1, _ref2, _results;
      _ref = data.skiers;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        skier = _ref[_i];
        if ((_ref1 = skier.color) == null) {
          skier.color = "black";
        }
        this.context.strokeStyle = skier.color;
        this.context.beginPath();
        this.context.moveTo(transX(skier.positions[0][0]), transY(skier.positions[0][1]));
        _ref2 = skier.positions.slice(0);
        for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
          pair = _ref2[_j];
          x = transX(pair[0]);
          y = transY(pair[1]);
          this.context.lineTo(x, y);
        }
        _results.push(this.context.stroke());
      }
      return _results;
    };

    HomePageView.prototype.drawIntermediate = function(data) {
      var pair, x, y, _i, _len, _ref;
      this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
      this.drawGates();
      this.context.beginPath();
      this.context.moveTo(transX(data.best[0][0]), transY(data.best[0][1]));
      _ref = data.best.slice(0);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        pair = _ref[_i];
        x = transX(pair[0]);
        y = transY(pair[1]);
        this.context.lineTo(x, y);
      }
      return this.context.stroke();
    };

    HomePageView.prototype.drawGates = function() {
      var closerDistanceSkierPole, factor, flagWidth, gate, gateWidth, gates, i, isClosed, isLeft, pair, x, y, _i, _len, _ref;
      gates = zip(this.giantGates, this.closedGates, this.hasLeftSidePollGates);
      flagWidth = 0.75;
      gateWidth = 10;
      closerDistanceSkierPole = 0.2;
      _ref = gates.slice(0);
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        gate = _ref[i];
        pair = gate[0];
        isClosed = gate[1];
        isLeft = gate[2];
        if (isLeft) {
          factor = 1;
        } else {
          factor = -1;
        }
        this.context.beginPath();
        this.context.lineWidth = 5;
        if (this.toggle) {
          this.context.strokeStyle = 'blue';
        } else {
          this.context.strokeStyle = 'red';
        }
        x = transX(pair[0] + factor * closerDistanceSkierPole);
        y = transY(pair[1]);
        this.context.moveTo(x, y);
        this.context.lineTo(transX(pair[0] + factor * flagWidth), y);
        if (!isClosed) {
          this.context.moveTo(transX(pair[0] - factor * gateWidth), y);
          this.context.lineTo(transX(pair[0] - factor * (gateWidth + flagWidth)), y);
          this.context.stroke();
        } else {
          this.context.moveTo(x, transY(pair[1] + gateWidth - 2 * flagWidth));
          this.context.lineTo(transX(pair[0] + factor * (closerDistanceSkierPole + flagWidth)), transY(pair[1] + gateWidth - 2 * flagWidth));
          this.context.stroke();
        }
        this.toggle = !this.toggle;
      }
      this.context.lineWidth = 1;
      return this.context.strokeStyle = 'black';
    };

    HomePageView.prototype.renderResults = function(data) {
      return general_chart(this.avgFitness, this.bestFitness, this.worstFitness);
    };

    HomePageView.prototype.processStatistics = function(data) {
      if (data.plugin === "AverageFitness") {
        this.avgFitness.push(data.value);
        return this.chart.series[0].addPoint([(new Date()).getTime(), data.value], false, true);
      } else if (data.plugin === "BestFitness") {
        this.bestFitness.push(data.value);
        return this.chart.series[1].addPoint([(new Date()).getTime(), data.value], false, true);
      } else if (data.plugin === "WorstFitness") {
        this.worstFitness.push(data.value);
        return this.chart.series[2].addPoint([(new Date()).getTime(), data.value], true, true);
      }
    };

    HomePageView.prototype.work = function() {
      var i,
        _this = this;
      i = 0;
      this.getProblemButton.hide();
      this.dancers.show();
      this.computationContainer.show();
      this.worker.onmessage = function(event) {
        i += 1;
        if (event.data.type === 'final') {
          _this.draw(event.data);
          _this.renderResults(event.data);
          event.data.problem_id = _this.problemId;
          event.data.type = "GIANT_RESULT";
          _this.dancers.fadeOut;
          _this.success.show();
          if ((!_this.bestTimeUserFound) || _this.bestTimeUserFound > event.data.bestTime) {
            _this.bestTimeUserFound = event.data.bestTime;
            _this.bestYouFound.html(event.data.bestTime);
          }
          _this.problem.postResult(event.data, function() {
            _this.work();
            _this.success.hide();
            _this.numberOfSolved += 1;
            _this.nsolved.html(_this.numberOfSolved);
            return _this.problem.getBestResult(function(bestResultInDb) {
              return _this.bestWeHave.html(bestResultInDb);
            });
          });
        }
        if (event.data.type === 'intermediate') {
          _this.drawIntermediate(event.data);
        }
        if (event.data.type === "stats") {
          return _this.processStatistics(event.data);
        } else {
          return console.log(event.data);
        }
      };
      return this.worker.postMessage({
        gates: zip(this.giantGates, this.closedGates),
        hasLeftSidePollGates: this.hasLeftSidePollGates
      });
    };

    return HomePageView;

  })(PageView);

  zip = function() {
    var arr, i, length, lengthArray, _i, _results;
    lengthArray = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = arguments.length; _i < _len; _i++) {
        arr = arguments[_i];
        _results.push(arr.length);
      }
      return _results;
    }).apply(this, arguments);
    length = Math.min.apply(Math, lengthArray);
    _results = [];
    for (i = _i = 0; 0 <= length ? _i < length : _i > length; i = 0 <= length ? ++_i : --_i) {
      _results.push((function() {
        var _j, _len, _results1;
        _results1 = [];
        for (_j = 0, _len = arguments.length; _j < _len; _j++) {
          arr = arguments[_j];
          _results1.push(arr[i]);
        }
        return _results1;
      }).apply(this, arguments));
    }
    return _results;
  };
  
}});

window.require.define({"views/layout": function(exports, require, module) {
  var Chaplin, Layout,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Chaplin = require('chaplin');

  module.exports = Layout = (function(_super) {

    __extends(Layout, _super);

    function Layout() {
      return Layout.__super__.constructor.apply(this, arguments);
    }

    Layout.prototype.initialize = function() {
      return Layout.__super__.initialize.apply(this, arguments);
    };

    return Layout;

  })(Chaplin.Layout);
  
}});

window.require.define({"views/login_view": function(exports, require, module) {
  var LoginView, View, template, utils,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  utils = require('lib/utils');

  View = require('views/base/view');

  template = require('views/templates/login');

  module.exports = LoginView = (function(_super) {

    __extends(LoginView, _super);

    function LoginView() {
      return LoginView.__super__.constructor.apply(this, arguments);
    }

    LoginView.prototype.template = template;

    LoginView.prototype.id = 'login';

    LoginView.prototype.container = '#content-container';

    LoginView.prototype.autoRender = true;

    LoginView.prototype.initialize = function(options) {
      LoginView.__super__.initialize.apply(this, arguments);
      return this.initButtons(options.serviceProviders);
    };

    LoginView.prototype.initButtons = function(serviceProviders) {
      var buttonSelector, failed, loaded, loginHandler, serviceProvider, serviceProviderName, _results;
      _results = [];
      for (serviceProviderName in serviceProviders) {
        serviceProvider = serviceProviders[serviceProviderName];
        buttonSelector = "." + serviceProviderName;
        this.$(buttonSelector).addClass('service-loading');
        loginHandler = _(this.loginWith).bind(this, serviceProviderName, serviceProvider);
        this.delegate('click', buttonSelector, loginHandler);
        loaded = _(this.serviceProviderLoaded).bind(this, serviceProviderName, serviceProvider);
        serviceProvider.done(loaded);
        failed = _(this.serviceProviderFailed).bind(this, serviceProviderName, serviceProvider);
        _results.push(serviceProvider.fail(failed));
      }
      return _results;
    };

    LoginView.prototype.loginWith = function(serviceProviderName, serviceProvider, event) {
      event.preventDefault();
      if (!serviceProvider.isLoaded()) {
        return;
      }
      this.publishEvent('login:pickService', serviceProviderName);
      return this.publishEvent('!login', serviceProviderName);
    };

    LoginView.prototype.serviceProviderLoaded = function(serviceProviderName) {
      return this.$("." + serviceProviderName).removeClass('service-loading');
    };

    LoginView.prototype.serviceProviderFailed = function(serviceProviderName) {
      return this.$("." + serviceProviderName).removeClass('service-loading').addClass('service-unavailable').attr('disabled', true).attr('title', "Error connecting. Please check whether you areblocking " + (utils.upcase(serviceProviderName)) + ".");
    };

    return LoginView;

  })(View);
  
}});

window.require.define({"views/templates/header": function(exports, require, module) {
  module.exports = Handlebars.template(function (Handlebars,depth0,helpers,partials,data) {
    helpers = helpers || Handlebars.helpers;
    var foundHelper, self=this;


    return "<div id=\"fb-root\"></div>\r\n<script>(function(d, s, id) {\r\n  var js, fjs = d.getElementsByTagName(s)[0];\r\n  if (d.getElementById(id)) return;\r\n  js = d.createElement(s); js.id = id;\r\n  js.src = \"//connect.facebook.net/en_US/all.js#xfbml=1&appId=348707178584637\";\r\n  fjs.parentNode.insertBefore(js, fjs);\r\n}(document, 'script', 'facebook-jssdk'));</script>";});
}});

window.require.define({"views/templates/home": function(exports, require, module) {
  module.exports = Handlebars.template(function (Handlebars,depth0,helpers,partials,data) {
    helpers = helpers || Handlebars.helpers;
    var foundHelper, self=this;


    return "﻿<div class=\"container\">\r\n	<div class=\"row\">\r\n	  \r\n		<center>\r\n			<h2>\r\n			We find the fastest track, the alpine skier should take in order to win!\r\n			</h2>\r\n			<h4>\r\n				Created as a master thesis at AGH University of Science and Technology.</br>March 2012 - May 2013.\r\n				<img style=\"margin: 10px;\" src=\"img/test/notepad.gif\">\r\n			</h4>\r\n			<div>	\r\n			<img src=\"img/test/new.gif\">\r\n			<button id=\"get-problem-button\" class=\"btn btn-primary\"> Show me !! </button>\r\n			<div id=\"dancers\">\r\n				<img src=\"img/test/mchammer.gif\">\r\n				<img src=\"img/test/mchammer.gif\">\r\n				<img src=\"img/test/mchammer.gif\">\r\n			</div>\r\n			</div>\r\n			<div class=\"fb-like\" data-href=\"http://giant-client.herokuapp.com/\" data-width=\"450\" data-show-faces=\"true\"></div>\r\n			<div id=\"success\" class=\"alert alert-success\" style=\"display: none;\" >\r\n				<a class=\"close\">×</a>\r\n				<strong>Success</strong>Thanks - we got result of your computation. All world skiers will love you! Note that every time you or your frineds click the button and start the computations, this first world problem is closer to be solved! So share!\r\n		\r\n			  </div>\r\n		</center>\r\n	</div>\r\n	<div class=\"row\" id=\"computation\" >\r\n		<h4>\r\n			What you see here is a giant slalom and our algorithm that finds the fastest tract for the skier. The problem instance was requested from our server. All the computations are run in your browser and will be send to our server once it is done. \r\n		</h4>\r\n		<h3>Number of solved problems: <span id=\"nsolved\"> 0 </span></h3>\r\n		<h3>Best time you found: <span id=\"bestYouFound\"> 0 </span></h3>\r\n		<h3>Best time we have so far: <span id=\"bestWeHave\"> 0 </span></h3>\r\n		<div class=\"span4\">\r\n			<div id=\"stats_container\" style=\"width: 400px; height: 400px;\"></div>\r\n			<div id=\"general_stats_container\" style=\"width: 400px; height: 400px;\"></div>\r\n		</div>\r\n		<div class=\"span8\">\r\n			<canvas id=\"slope\" width=\"3000px\" height=\"1500px\"></canvas>\r\n		</div>\r\n		<h2> Relax. While the computations are running, you can play the game. </h2>\r\n		<a id=\"musicoff\" class=\"btn btn-info btn-large\" href=\"#\">Turn off the music!! (but the game will disappear :/)</a>\r\n		<!-- <iframe id=\"game\" width=\"100%\" height=\"600px\" src=\"http://uploads.ungrounded.net/473000/473755_skifree.swf\"></iframe> -->\r\n	</div>\r\n	\r\n	\r\n				<center>\r\n        <img src=\"img/test/yahooweek.gif\">\r\n        <img src=\"img/test/community.gif\">\r\n        <img src=\"img/test/wabwalk.gif\">\r\n        <img src=\"img/test/webtrips.gif\">\r\n      </center>\r\n	\r\n	  <div>\r\n	  </br>\r\n	  </br>\r\n	  <p class=\"pull-right\" style=\"margin-top: -14px\"><img src=\"img/test/hacker.gif\">&nbsp; Built by Anna Skiba, Marta Ryłko & dr. inż. Roman Dębski <a href=\"https://github.com/martar/optimal-gigant/wiki\">More details behind this project..</a></p>\r\n		\r\n	  </div>\r\n	<!--<div class=\"row\">\r\n		<div class=\"span12\">\r\n				<img id=\"image\" width=\"3000px\" height=\"5000px\" src=\"img/lol.jpg\" ></img>\r\n		</div>\r\n	</div>-->\r\n</div>\r\n\r\n\r\n\r\n\r\n\r\n\r\n";});
}});

window.require.define({"views/templates/login": function(exports, require, module) {
  module.exports = Handlebars.template(function (Handlebars,depth0,helpers,partials,data) {
    helpers = helpers || Handlebars.helpers;
    var buffer = "", foundHelper, self=this;


    return buffer;});
}});

