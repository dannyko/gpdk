class @Ship # designed for Gameprez by Thomas Birdsey, http://twitter.com/Tbirdsey
  @viper: -> {path: [
             {pathSegTypeAsLetter: 'M', x: 0,  y: -24, react: true},
             {pathSegTypeAsLetter: 'L', x: 24,  y: 38, react: true},
             {pathSegTypeAsLetter: 'L', x: 9,  y: 58, react: true},
             {pathSegTypeAsLetter: 'L', x: 3,  y: 48, react: true},
             {pathSegTypeAsLetter: 'L', x: -3,  y: 48, react: true},
             {pathSegTypeAsLetter: 'L', x: -9,  y: 58, react: true},
             {pathSegTypeAsLetter: 'L', x: -24,  y:38, react: true},
             {pathSegTypeAsLetter: 'Z'}
          ], url: "assets/images/viper_1.png", offset: {x: 0, y: 19}}

  @fang: -> {path: [
            {pathSegTypeAsLetter: 'M', x: 10,  y: -20, react: true}, 
            {pathSegTypeAsLetter: 'L', x: 30,  y: -10, react: true}, 
            {pathSegTypeAsLetter: 'L', x: 40,  y: 20, react: true}, 
            {pathSegTypeAsLetter: 'L', x: 30,  y: 50, react: true}, 
            {pathSegTypeAsLetter: 'L', x: 15,  y: 60, react: true}, 
            {pathSegTypeAsLetter: 'L', x: 10,  y: 67, react: true}, 
            {pathSegTypeAsLetter: 'L', x: 5,  y: 70, react: true},
            {pathSegTypeAsLetter: 'L', x: -5,  y: 70, react: true}, 
            {pathSegTypeAsLetter: 'L', x: -10,  y: 67, react: true}, 
            {pathSegTypeAsLetter: 'L', x: -15,  y: 60, react: true}, 
            {pathSegTypeAsLetter: 'L', x: -30,  y: 50, react: true}, 
            {pathSegTypeAsLetter: 'L', x: -40,  y: 20, react: true}, 
            {pathSegTypeAsLetter: 'L', x: -30,  y: -10, react: true}, 
            {pathSegTypeAsLetter: 'L', x: -10,  y: -20, react: true}, 
            {pathSegTypeAsLetter: 'L', x: -5,  y: 40, react: true}, 
            {pathSegTypeAsLetter: 'L', x: 5,  y: 40, react: true}, 
            {pathSegTypeAsLetter: 'Z', react: true}
          ], url: "assets/images/fang_1.png", offset: {x: 0, y: 25}}

  @sidewinder: -> {path: [{pathSegTypeAsLetter: 'M', x:  8,  y: -26, react: true},  
                        {pathSegTypeAsLetter: 'L', x:  32, y: -14, react: true}, 
                        {pathSegTypeAsLetter: 'L', x:  44, y:  18, react: true}, 
                        {pathSegTypeAsLetter: 'L', x:  32, y:  26, react: true}, 
                        {pathSegTypeAsLetter: 'L', x:  30, y:  18, react: true}, 
                        {pathSegTypeAsLetter: 'L', x: -28, y:  18, react: true}, 
                        {pathSegTypeAsLetter: 'L', x: -32, y:  26, react: true}, 
                        {pathSegTypeAsLetter: 'L', x: -44, y:  18, react: true},
                        {pathSegTypeAsLetter: 'L', x: -32, y: -14, react: true},
                        {pathSegTypeAsLetter: 'L', x: -8,  y: -26, react: true},
                        {pathSegTypeAsLetter: 'L', x: -8,  y: -14, react: true},
                        {pathSegTypeAsLetter: 'L', x:  8,  y: -14, react: true},
                        {pathSegTypeAsLetter: 'Z'}
		   	        ], url: "assets/images/sidewinder_1.png", offset: {x: 0, y: 0}}