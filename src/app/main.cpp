#include <filament/FilamentAPI.h>
#include <filament/Engine.h>

using namespace filament;

int main(int argc, char** argv)
{
    Engine *engine = Engine::create();
    engine->destroy(&engine);
    return 0;
}