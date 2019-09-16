// MIT License
//
// Copyright (c) 2019 Cuberto Design <info@cuberto.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
part of 'pager.dart';

class _LiquidSwipeMath {
  static const double initialHorRadius = 48.0;
  static const double initialVertRadius = 82.0;
  static const double initialSideWidth = 15.0;

  static double initialWaveCenter(double height) => height * 0.7167487685;

  static double maxHorRadius(double width) => width * 0.8;

  static double maxVertRadius(double height) => height * 0.9;

  static double waveHorRadius(double progress, double width) {
    if (progress <= 0) {
      return initialHorRadius;
    }
    if (progress >= 1) {
      return 0;
    }
    double p1 = 0.4;
    if (progress <= p1) {
      return initialHorRadius + progress / p1 * (maxHorRadius(width) - initialHorRadius);
    }
    double t = (progress - p1) / (1.0 - p1);
    double A = maxHorRadius(width);
    double r = 40;
    double m = 9.8;
    double beta = r / (2 * m);
    double k = 50;
    double omega0 = k / m;
    double omega = math.pow(-math.pow(beta, 2) + math.pow(omega0, 2), 0.5);
    return A * math.exp(-beta * t) * math.cos(omega * t);
  }

  static double waveHorRadiusBack(double progress) {
    if (progress <= 0) {
      return initialHorRadius;
    }
    if (progress >= 1) {
      return 0;
    }
    double p1 = 0.4;
    if (progress <= p1) {
      return initialHorRadius + progress / p1 * initialHorRadius;
    }
    double t = (progress - p1) / (1.0 - p1);
    double A = 2 * initialHorRadius;
    double r = 40;
    double m = 9.8;
    double beta = r / (2 * m);
    double k = 50;
    double omega0 = k / m;
    double omega = math.pow(-math.pow(beta, 2) + math.pow(omega0, 2), 0.5);
    return A * math.exp(-beta * t) * math.cos(omega * t);
  }

  static double waveVertRadius(double progress, double height) {
    double p1 = 0.4;
    if (progress <= 0) {
      return initialVertRadius;
    }
    if (progress >= p1) {
      return maxVertRadius(height);
    }
    return initialVertRadius + (maxVertRadius(height) - initialVertRadius) * progress / p1;
  }

  static double sideWidth(double progress, double width) {
    double p1 = 0.2;
    double p2 = 0.8;
    if (progress <= p1) {
      return initialSideWidth;
    }
    if (progress >= p2) {
      return width;
    }
    return initialSideWidth + (width - initialSideWidth) * (progress - p1) / (p2 - p1);
  }
}
