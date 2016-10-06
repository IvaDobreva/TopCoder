#include <string>

using namespace std;

class Time {

	public: string whatTime(int seconds) {
		int h, m, s;
		string hour;

		h = seconds/3600;
		seconds -=h*3600;
		m = (seconds)/60;
		seconds -= m*60;
		s = seconds;

		hour = to_string(h) + ":" +to_string(m) + ":" + to_string(s);

		return hour;
	}

};
