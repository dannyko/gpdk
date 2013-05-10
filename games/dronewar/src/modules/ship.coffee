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
          ], url: GameAssetsUrl + "viper_1.png", offset: {x: 0, y: 19}, bullet_stroke: 'none', bullet_fill: '#fff', bullet_size: 2, bullet_speed: 15, bullet_tick: 25}

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
          ], url: GameAssetsUrl + "fang_1.png", offset: {x: 0, y: 25}, bullet_stroke: '#fff', bullet_fill: 'none', bullet_size: 5, bullet_speed: 10, bullet_tick: 20}

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
		   	        ], url: GameAssetsUrl + "sidewinder_1.png", offset: {x: 0, y: 0}, bullet_stroke: 'none', bullet_fill: '#000', bullet_size: 4, bullet_speed: 10, bullet_tick: 30}