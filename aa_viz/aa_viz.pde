import processing.sound.*;

SoundFile song;
String song_path = "../data/wknd_w.wav";

int ms;
float curr_time;
int init_time;
float time_pos;

JSONObject json;

float test_point = 0.0;

float point_pos;
float point_x;
float point_y;
float total_pixels;

float song_duration;

float duration_limit = 60.0;

int pitch_line_wgt = 5;
int vert_div = 14 * pitch_line_wgt;

float tatum_line_wgt = 0.5;
float beat_line_wgt = 1.5;
float bar_line_wgt = 3;
float section_line_wgt = 4;

color tatum_col;
color beat_col;
color bar_col;
color section_col;

JSONArray tatums;
JSONArray beats;
JSONArray bars;
JSONArray sections;
JSONArray segments;

void setup() {
	size(720, 960);
	background(255);

	colorMode(HSB, 360, 1.0, 1.0, 1.0);
	tatum_col = color(0.0, 0.0, 0.1, 1.0);
	beat_col = color(0.0, 0.0, 0.0 ,1.0);
	bar_col = color(0.0, 0.0, 0.0 ,1.0);
	section_col = color(120, 1.0, 1.0, 1.0);

	total_pixels = width*height;


	json = loadJSONObject("../data/blinding_lights_audio_features.json");

	JSONObject track_info = json.getJSONObject("track");
	
	song_duration = track_info.getFloat("duration");
	tatums = json.getJSONArray("tatums");
	beats = json.getJSONArray("beats");
	bars = json.getJSONArray("bars");
	sections = json.getJSONArray("sections");
	segments = json.getJSONArray("segments");
	//JSONObject tatum0 = tatums.getJSONObject(tatums.size()-1);

	// print(tatums.size());
	//println(tatum0);
	println("song_duration: "+song_duration);

	subdivisionLines(tatums, tatum_line_wgt, tatum_col);
	subdivisionLines(beats, beat_line_wgt, beat_col);
	subdivisionLines(bars, bar_line_wgt, bar_col);
	subdivisionLines(sections, section_line_wgt, section_col);

	strokeWeight(pitch_line_wgt);

	for (int i = 0; i < segments.size()-1; ++i) {
		JSONObject o1 = segments.getJSONObject(i);
		JSONObject o2 = segments.getJSONObject(i+1);

		JSONArray pitches = o1.getJSONArray("pitches");

		float point_pos1 = map(o1.getFloat("start"), 0.0, duration_limit, 0, total_pixels);
		float point_pos2 = map(o2.getFloat("start"), 0.0, duration_limit, 0, total_pixels);

		float point_x1 = ((point_pos1/vert_div)%width);
		float point_y1 = (point_pos1/width) - ((point_pos1/width)%vert_div);

		float point_x2 = ((point_pos2/vert_div)%width);
		float point_y2 = (point_pos2/width) - ((point_pos2/width)%vert_div);

		for (int j = 0; j < pitches.size(); ++j) {
			float pitch = pitches.getFloat(j);
			float yoff = (11-j)*pitch_line_wgt;
			stroke(0.0, 0.0, 0.0, pitch);
			if (point_y2==point_y1) {
				line(point_x1, point_y1+yoff, point_x2, point_y2+yoff);
			}
			else if (point_y2>point_y1) {
				line(point_x1, point_y1+yoff, width, point_y1+yoff);
				line(0, point_y2+yoff, point_x2, point_y2+yoff);
			}
			
		}
	}



	song = new SoundFile(this, song_path);
	song.amp(0.5);
	song.play();
	//song.rate(song.duration()/song_duration);
	println("File Duration= " + song.duration() + " seconds");

}

void draw() {
	if (frameCount == 1) {
		init_time = millis();
		println("playing: "+song.isPlaying());
	}
	ms = millis();
	curr_time = float(ms-init_time)/1000.0;

	time_pos = map(curr_time, 0.0, duration_limit, 0, total_pixels);


	point_x = ((time_pos/vert_div)%width);
	point_y = (time_pos/width) - ((time_pos/width)%vert_div);

	stroke(0, 1.0, 1.0, 0.2);
	strokeWeight(3);
	line(point_x, point_y, point_x, point_y+(12*pitch_line_wgt));
	//time
	//background(0, 0.0, 1.0, 1.0);
	//strokeWeight(tatum_line_wgt);



	// for (int i = 0; i < tatums.size(); ++i) {
	// 	JSONObject t = tatums.getJSONObject(i);
	// 	float pos_time = t.getFloat("start");
	// 	//print(pos_time);
	// 	// float time_ratio = map(pos_time, 0.0, song_duration, 0.0, 1.0 );

	// 	point_pos = map(pos_time, 0.0, duration_limit, 0, total_pixels);
	// 	point_x = ((point_pos/vert_div)%width);
	// 	point_y = (point_pos/width) - ((point_pos/width)%vert_div);

	// 	//stroke(map(pos_time, 0, song_duration, 0, 255*10)%255);
	// 	stroke(0.0, 0.0, 0.1 ,1.0 );
	// 	line(point_x, point_y, point_x, point_y+(12*pitch_line_wgt));
	// 	//point(point_x, point_y);

	// 	if (pos_time>duration_limit){
	// 		break;
	// 	}
	// }


}

void subdivisionLines(JSONArray subdiv, float line_wgt, color line_col){
	stroke(line_col);
	strokeWeight(line_wgt);

	for (int i = 0; i < subdiv.size(); ++i) {
		JSONObject o = subdiv.getJSONObject(i);
		float pos_time = o.getFloat("start");
		//print(pos_time);
		// float time_ratio = map(pos_time, 0.0, song_duration, 0.0, 1.0 );

		point_pos = map(pos_time, 0.0, duration_limit, 0, total_pixels);
		point_x = ((point_pos/vert_div)%width);
		point_y = (point_pos/width) - ((point_pos/width)%vert_div);

		//stroke(map(pos_time, 0, song_duration, 0, 255*10)%255);
		line(point_x, point_y, point_x, point_y+(12*pitch_line_wgt));
		//point(point_x, point_y);

		if (pos_time>duration_limit){
			break;
		}

		
	}

}