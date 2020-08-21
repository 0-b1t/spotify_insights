//import processing.sound.*;

import ddf.minim.*;

Minim minim;
AudioPlayer song;

//SoundFile song;
String song_path = "../data/let_it_be.mp3";
String features_path = "../data/let_it_be_audio_features.json";

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

int pitch_line_wgt = 10;
int vert_div = 14 * pitch_line_wgt;
int hor_div = 5;

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

	rectMode(CORNERS);
	strokeCap(SQUARE);

	total_pixels = width*height;


	json = loadJSONObject(features_path);

	JSONObject track_info = json.getJSONObject("track");
	
	song_duration = track_info.getFloat("duration");
	tatums = json.getJSONArray("tatums");
	beats = json.getJSONArray("beats");
	bars = json.getJSONArray("bars");
	sections = json.getJSONArray("sections");
	segments = json.getJSONArray("segments");

	println("song_duration: "+song_duration);

	subdivisionLines(tatums, tatum_line_wgt, tatum_col);
	subdivisionLines(beats, beat_line_wgt, beat_col);
	subdivisionLines(bars, bar_line_wgt, bar_col);
	subdivisionLines(sections, section_line_wgt, section_col);

	//drawSegments(segments);


	minim = new Minim(this);
	song = minim.loadFile(song_path);
	println(float(song.length())/1000.0);
	song.play();

}

void draw() {

	time_pos = map(float(song.position())/1000.0, 0.0, duration_limit, 0, total_pixels);


	point_x = ((time_pos/hor_div)%width);
	point_y = (time_pos/width) - ((time_pos/width)%vert_div);

	stroke(240, 1.0, 1.0, 0.05);
	strokeWeight(3);
	line(point_x, point_y, point_x, point_y+(12*pitch_line_wgt));


}

void subdivisionLines(JSONArray subdiv, float line_wgt, color line_col){
	stroke(line_col);
	strokeWeight(line_wgt);

	for (int i = 0; i < subdiv.size(); ++i) {
		JSONObject o = subdiv.getJSONObject(i);

		float pos_time = o.getFloat("start");

		point_pos = map(pos_time, 0.0, duration_limit, 0, total_pixels);
		point_x = ((point_pos/vert_div)%width);
		point_y = ((point_pos)/width) - ((point_pos/width)%vert_div);

		line(point_x, point_y, point_x, point_y+(12*pitch_line_wgt));

		if (pos_time>duration_limit){
			break;
		}		
	}
}

void drawSegments(JSONArray segs){
	for (int i = 0; i < segs.size()-1; ++i) {
		JSONObject o1 = segs.getJSONObject(i);
		JSONObject o2 = segs.getJSONObject(i+1);

		JSONArray pitches = o1.getJSONArray("pitches");

		float point_pos1 = map(o1.getFloat("start"), 0.0, duration_limit, 0, total_pixels);
		float point_pos2 = map(o2.getFloat("start"), 0.0, duration_limit, 0, total_pixels);

		float point_x1 = ((point_pos1/vert_div)%width);
		float point_y1 = (point_pos1/width) - ((point_pos1/width)%vert_div);

		float point_x2 = ((point_pos2/vert_div)%width);
		float point_y2 = (point_pos2/width) - ((point_pos2/width)%vert_div);

		float confidence_alpha = map(o1.getFloat("confidence"), 0.0, 1.0, 0.5, 0.0);

		fill(0, 1.0, 1.0, confidence_alpha); //red
		noStroke();

		rect(point_x1, point_y1, point_x2, point_y2+12*pitch_line_wgt); //confidence of the segment

		for (int j = 0; j < pitches.size(); ++j) {
			float pitch = pitches.getFloat(j);
			float yoff = (11-j)*pitch_line_wgt;
			noStroke();
			fill(0.0, 0.0, 0.0, pitch);
			if (point_y2==point_y1) {
				rect(point_x1, point_y1+yoff, point_x2, point_y2+yoff+pitch_line_wgt);
			}
			else if (point_y2>point_y1) {
				rect(point_x1, point_y1+yoff, width, point_y1+yoff+pitch_line_wgt);
				rect(0, point_y2+yoff, point_x2, point_y2+yoff+pitch_line_wgt);
			}
			
		}
	}
}