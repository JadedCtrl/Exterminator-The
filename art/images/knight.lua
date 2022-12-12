--[[

The MIT License (MIT)

Copyright (c) 2013 Patrick Rabier

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

]]

-- Made from the template `lib/love-animation/animation.template.lua`

return {
   imageSrc = "art/images/knight.png",
   defaultState = "neutral",

   states = {
	  neutral = {
		 frameCount = 1,
		 offsetX = 0,
		 offsetY = 0,
		 frameW = 14,
		 frameH = 16,
		 nextState = "neutral",
		 switchDelay = 0
	  },

	  upward = {
		 frameCount = 1,
		 offsetX = 15,
		 offsetY = 0,
		 frameW = 13,
		 frameH = 19,
		 nextState = "upward",
		 switchDelay = 0
	  },

	  downward = {
		 frameCount = 1,
		 offsetX = 29,
		 offsetY = 0,
		 frameW = 13,
		 frameH = 17,
		 nextState = "downward",
		 switchDelay = 0
	  },

	  side = {
		 frameCount = 1,
		 offsetX = 43,
		 offsetY = 0,
		 frameW = 21,
		 frameH = 16,
		 nextState = "side",
		 switchDelay = 0
	  }
   }
}
